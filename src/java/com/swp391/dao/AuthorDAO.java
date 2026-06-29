package com.swp391.dao;

import com.swp391.model.Author;
import java.util.List;

public interface AuthorDAO {
    Author create(Author author) throws Exception;
    Author findById(int id) throws Exception;
    List<Author> findAll() throws Exception;
    Author findByName(String name) throws Exception;
    boolean update(Author author) throws Exception;
    boolean delete(int id, String deletedBy) throws Exception;

    // Search, count & validations
    List<Author> search(String keyword, String sortField, String sortOrder, int page, int pageSize) throws Exception;
    int count(String keyword) throws Exception;
    boolean isNameExists(String name) throws Exception;
    boolean isNameExistsExcluding(String name, int excludeId) throws Exception;
    boolean hasActiveBooks(int authorId) throws Exception;
}
