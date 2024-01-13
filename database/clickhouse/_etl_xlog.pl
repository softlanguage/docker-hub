#!/usr/bin/env perl
use strict;
use warnings;
use POSIX 'strftime';
use Scalar::Util qw(looks_like_number);

# # Format as YYYY-MM-DD HH:MM:SS
sub get_short_time { return POSIX::strftime('%Y%m%d_%H%M%S', localtime); }
sub get_short_date { return int(POSIX::strftime('%Y%m%d', localtime)); }


sub subtract_days {
	my ($sub_val) = shift;
	my $epoc = time();
	my $epoc = $epoc - ($sub_val * 24 * 60 * 60);   # 365 days before today
	my $t1 = POSIX::strftime('%Y%m%d', localtime($epoc));
	return $t1;
}

# Format as YYYY-MM-DD HH:MM:SS
sub get_neat_time { return POSIX::strftime('%Y-%m-%d %H:%M:%S', localtime); }
sub prints { my $now = get_neat_time(); my @log = @_; printf "$now --> @log\n"; }

printf("\n\n- - - - - - - - - - - -- - - - - - - - - - - -\n");


sub exec_pipe {
	open(my $pipe, "-|", @_) or die "Error: can't open @_";
	my $result=''; # print $line;
	while (my $line = <$pipe>) { $result.=$line; }
	close($pipe);
	return $result;
}

# -- EOF for SQL
sub query_ck_xlog {

	#my $r1 = qx/clickhouse-client -d prd_zyb_xlog -mn "@_"/;
	return exec_pipe('clickhouse-client', '-d', 'prd_zyb_xlog', '-mn', '-q', @_);
}


sub exec_postgresql {
	my ($sql2) = shift;
	$ENV{PGPASSWORD}='xxx';
	my $r1 = exec_pipe('psql', '-dpostgres', '-h10.8.8.204', '-p5432', '-Uzyb', '-c',$sql2);
	prints $r1;
}


# q/STRING/, or q(STRING) - Single Quotes, does not allow interpolation.
# qq/STRING/, or qq(STRING) - Double Quotes, allow interpolation.

my $sql1 = qq/
select 'Hello Clickhouse version of' as hello, version();
/;

prints query_ck_xlog($sql1);

# today, count_at_ck, count_at_pg
sub get_max_today_in_ck{
	my ($yesterday) = shift;

	my $sql2 = qq/
with (select ifNull(max(today), 0) from app_logs where today<=$yesterday) as maxday
select maxday as maxday_ck, count(1) as cnt_ck, 
(select count(1) from pg_xlog.app_logs where today=maxday) as cnt_pg,
(select ifNull(min(today), 0) from pg_xlog.app_logs where today>maxday and today<=$yesterday) as bear_day
from app_logs where today=maxday;
/;
	my $r1 = query_ck_xlog($sql2);

	# parse result to: maxday_ck, cnt_ck, cnt_pg, bear_day_pg
	my @numbers = split /\s+/, $r1;
	@numbers = grep { $_ ne "" or $_ == 0 } @numbers;

	if (scalar @numbers==4){
		foreach my $element (@numbers) {
			if(!looks_like_number($element)){
				prints('please check the query result:',$r1);
				die __LINE__."❌ Check the query result: $r1";
			}
		}
	}else{
		die __LINE__."❌ Check count of query result: $r1, @numbers";
	}

	if ($numbers[1] != $numbers[2]) {
		warn __LINE__."❗ Warning: clickhouse=$numbers[1], but pgdb=$numbers[2]";
	}

	return @numbers;
}


sub bearing_xlog{
	my ($workday) = shift;
	my $sql2 = qq/
INSERT INTO prd_zyb_xlog.app_logs SELECT 
id, `uuid`, title, content, operate_type, biz_id, biz_code, biz_name, url, service_ip, client_ip, 
req_control, req_method, req_time, user_id, app_id, author, created, editor, modified, today, cost_time
FROM pg_xlog.app_logs
where today=$workday;
/;
	prints($sql2);
	query_ck_xlog($sql2);
}

my $bear_limit=5;


sub bear_logs{
	my $yesterday = get_short_date() - 1;

	prints("yesterday is", $yesterday);
	my @nnn = get_max_today_in_ck($yesterday);
	prints('numbers:', @nnn);

	my ($maxday_ck, $cnt_ck, $cnt_pg, $bear_day_pg) = @nnn;
	prints("maxday_ck=$maxday_ck, count_ck=$cnt_ck, count_pg=$cnt_pg, bearing_day_pg=$bear_day_pg");
	my $workday=($cnt_ck >= $cnt_pg)? $bear_day_pg : $maxday_ck;

	if($workday > 0 && $workday<=$yesterday){
		prints("start to bear logs of $workday");

		# bearing
		bearing_xlog($workday);

		# try next day by bear_logs
		if(--$bear_limit > 0) {
			bear_logs();
		}
	}else{
		my $shink_day = $workday > 0 ? $workday : $yesterday;
		pg_xlog_shrink($shink_day);
		prints("Great, [app_logs] well done ✅ ");
	}

}

sub pg_xlog_shrink(){
	my ($shrink_day) = shift;
	$shrink_day -= 10;

	my $sql2 = qq/delete from log.app_logs where today < $shrink_day;/;

	#my $sql2 = qq/select version(), $shrink_day as "shrink_day";/;
	prints("shrink log.app_logs on pgdb $shrink_day: $sql2");
	my $r1 = exec_postgresql($sql2);
	prints $r1;
}


sub bear_pg_wblog() {
	my $bearing_day = get_short_date() - 1;
	my $ck_sql = qq/
insert INTO prd_zyb_xlog.wblog SELECT * from (
with (select ifNull(max(today), 0) from wblog where today<=$bearing_day) as maxday,
(select ifNull(max(today), 0) from pg_xlog.wblog where today<=$bearing_day) as bearing_day
select id, user_id, module_id, label_name, click_event, app_version, created, today
FROM pg_xlog.wblog where today > maxday and today <=bearing_day);
/;

	prints('bearing wblog:', $ck_sql);
	query_ck_xlog($ck_sql);

	my $shrink_day = subtract_days(100);
	my $pgsql = qq/delete from log.app_logs where today < $shrink_day;/;
	prints("shrink log.wblog on pgdb, $shrink_day: $pgsql");
	exec_postgresql($pgsql);
	prints("Great, [wblog] well done ✅ ");
}

bear_logs();
bear_pg_wblog();
