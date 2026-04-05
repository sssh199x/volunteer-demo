package com.demo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * =============================================
 * WHAT IS A SERVLET?
 * =============================================
 * A Servlet is a Java class that handles HTTP requests.
 * When someone visits a URL, Tomcat calls the appropriate
 * method in this Servlet:
 *   - GET request  (typing URL, clicking link) -> doGet()
 *   - POST request (submitting a form)         -> doPost()
 *
 * A Servlet acts as the CONTROLLER — it sits between
 * the browser and the JSP pages:
 *
 *   Browser --request--> Servlet --forward--> JSP --response--> Browser
 *
 * =============================================
 * @WebServlet ANNOTATION
 * =============================================
 * This tells Tomcat: "When someone visits /greeting, use THIS servlet."
 * Without this annotation, Tomcat wouldn't know which class handles which URL.
 */
@WebServlet("/greeting")
public class GreetingServlet extends HttpServlet {

    /**
     * doGet — handles GET requests (when you first visit the page).
     *
     * What happens:
     * 1. You visit http://localhost:9090/demo/greeting
     * 2. Tomcat calls this doGet() method
     * 3. It forwards to greeting.jsp (which shows the form)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Forward to the JSP page — this tells Tomcat:
        // "Send the user to the greeting.jsp page"
        //
        // Why /WEB-INF/views/? Files inside WEB-INF are HIDDEN from direct access.
        // You can't type /WEB-INF/views/greeting.jsp in the browser.
        // You MUST go through the servlet — this is the MVC pattern.
        request.getRequestDispatcher("/WEB-INF/views/greeting.jsp")
                .forward(request, response);
    }

    /**
     * doPost — handles POST requests (when you submit the form).
     *
     * What happens:
     * 1. You type your name and click "Greet Me"
     * 2. The form sends a POST request to /greeting
     * 3. Tomcat calls this doPost() method
     * 4. It reads the name, sets it as an attribute, and forwards to the JSP
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Step 1: Read the form data
        // "name" matches the <input name="name"> in the JSP form
        String name = request.getParameter("name");

        // Step 2: Set data as a request attribute
        // This makes "name" available in the JSP as ${name}
        // It's like putting data in a box that the JSP can open.
        request.setAttribute("name", name);

        // Step 3: Forward to the same JSP — but now it has the name data
        request.getRequestDispatcher("/WEB-INF/views/greeting.jsp")
                .forward(request, response);
    }
}
