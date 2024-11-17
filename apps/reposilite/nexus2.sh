set -e
cwd=$(realpath $(dirname $0))
sonatype_work=$cwd/sonatype-nexus
mkdir -p $sonatype_work && chown -R 200:200 $sonatype_work

# -e MAX_HEAP=768m, image=sonatype/nexus:2.15.2
docker run -d -m 1g -e MAX_HEAP=512m -p 8081:8081 --name nexus -v $sonatype_work:/sonatype-work softlang/sonatype-nexus:2.15.2

cat <<///README
--- readme ---
https://help.sonatype.com

# curl
# http://localhost:8081/nexus/service/local/status
# http://localhost:8081/nexus
# admin / admin123 (/sonatype-work/conf/security.xml)

# ~/.m2/settings.xml
<settings>
    <mirrors>
        <mirror>
            <id>mirror</id>
            <mirrorOf>*</mirrorOf>
            <name>mirror</name>
            <url>http://192.168.200.1:8081/nexus/content/groups/public/</url>
        </mirror>
    </mirrors>
</settings>
///README
