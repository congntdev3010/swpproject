package dao;

import model.Author;

import java.util.List;

public interface AuthorDAO {
    Author create(Author author) throws Exception;
    Author findById(int id) throws Exception;
    List<Author> findAll() throws Exception;
    Author findByName(String name) throws Exception;
    boolean update(Author author) throws Exception;
    boolean delete(int id) throws Exception;
}

