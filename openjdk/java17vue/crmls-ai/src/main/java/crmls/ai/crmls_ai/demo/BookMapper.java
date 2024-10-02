package crmls.ai.crmls_ai.demo;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface BookMapper {
@Select("select * from book")
  List<Book> findAll();

  @Select("SELECT * FROM book WHERE id = #{id}")
  Book findById(@Param("id") Long id);

  @Delete("DELETE FROM book WHERE id = #{id}")
  int deleteById(@Param("id") Long id);

  @Insert("INSERT INTO book(id, title, body) " +
      " VALUES (#{id}, #{title}, #{body})")
  int createNew(Book item);

  @Update("Update book set title=#{title}, " +
      " body=#{body} where id=#{id}")
  int update(Book item);
}
