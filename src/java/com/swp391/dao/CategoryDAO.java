package com.swp391.dao;

import com.swp391.model.Category;
import java.util.List;

public interface CategoryDAO {
    Category create(Category category) throws Exception;
    Category findById(int id) throws Exception;
    List<Category> findAll() throws Exception;
    boolean update(Category category) throws Exception;
    boolean delete(int id, String deletedBy) throws Exception;

    // Search, count & validations
    List<Category> search(String keyword, String sortField, String sortOrder, int page, int pageSize) throws Exception;
    int count(String keyword) throws Exception;
    boolean isNameExists(String name) throws Exception;
    boolean isNameExistsExcluding(String name, int excludeId) throws Exception;
    boolean hasActiveBooks(int categoryId) throws Exception;
}
