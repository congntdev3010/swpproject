package com.swp391.dao;

import com.swp391.model.User;
import java.util.List;

public interface UserDAO {
    User getUserById(int id) throws Exception;
    User getUserByUsername(String username) throws Exception;
    List<User> searchUsers(String q, String role, Integer active) throws Exception;
    int createUser(User user, String rawPassword) throws Exception;
    boolean updateUser(User user) throws Exception;
    boolean updatePassword(int userId, String hashedPassword) throws Exception;
    boolean deleteUser(int userId) throws Exception;
    boolean setActive(int userId, int active) throws Exception;
}

