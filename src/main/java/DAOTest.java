import dao.*;
import model.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class DAOTest {
    public static void main(String[] args) {
        try {
            // Test Category DAO
            CategoryDAO categoryDAO = new CategoryDAOImpl();
            System.out.println("✓ CategoryDAOImpl instantiated successfully");

            // Test Subject DAO
            SubjectDAO subjectDAO = new SubjectDAOImpl();
            System.out.println("✓ SubjectDAOImpl instantiated successfully");

            // Test Author DAO
            AuthorDAO authorDAO = new AuthorDAOImpl();
            System.out.println("✓ AuthorDAOImpl instantiated successfully");

            // Test Book DAO
            BookDAO bookDAO = new BookDAOImpl();
            System.out.println("✓ BookDAOImpl instantiated successfully");

            System.out.println("\n✓ All DAO implementations are syntactically correct!");

        } catch (Exception e) {
            System.out.println("✗ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

