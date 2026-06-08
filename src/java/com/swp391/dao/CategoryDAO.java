package com.swp391.dao;

import com.swp391.model.Category;
import java.util.List;

public interface CategoryDAO {
    Category create(Category category) throws Exception;
    Category findById(int id) throws Exception;
    List<Category> findAll() throws Exception;
    boolean update(Category category) throws Exception;
    boolean delete(int id) throws Exception;
}
