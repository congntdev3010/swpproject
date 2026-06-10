package dao;

import model.Book;

import java.util.List;

public interface BookDAO {
    Book create(Book book) throws Exception;
    Book findById(int id) throws Exception;
    Book findByIsbn(String isbn) throws Exception;
    List<Book> findAll() throws Exception;
    List<Book> findByCategoryId(int categoryId) throws Exception;
    List<Book> findBySubjectId(int subjectId) throws Exception;
    List<Book> findByPublisherId(int publisherId) throws Exception;
    List<Book> findByTitle(String title) throws Exception;
    boolean update(Book book) throws Exception;
    boolean delete(int id) throws Exception;
}

