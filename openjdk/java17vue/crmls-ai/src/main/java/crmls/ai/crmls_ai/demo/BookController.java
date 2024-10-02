package crmls.ai.crmls_ai.demo;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class BookController {

    @Autowired
    private BookMapper bookMapper;


    // In a real application, this would be retrieved from a database.
    private static List<Book> books = new ArrayList<>();

    static {
        books.add(new Book(1, "Hello world", "maven", 1925));
        books.add(new Book(2, "golang", "github", 1960));
        books.add(new Book(3, "Python", "pypi", 1949));
    }

    @GetMapping("/books/")
    public List<Book> getBooks() {
        return books;
    }

    @GetMapping("/mybooks/")
    public List<Book> getMyBooks() {
        return bookMapper.findAll();
    }
}

