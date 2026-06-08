package dao;

import model.Subject;

import java.util.List;

public interface SubjectDAO {
    Subject create(Subject subject) throws Exception;
    Subject findById(int id) throws Exception;
    List<Subject> findAll() throws Exception;
    List<Subject> findByCategoryId(int categoryId) throws Exception;
    boolean update(Subject subject) throws Exception;
    boolean delete(int id) throws Exception;
}

