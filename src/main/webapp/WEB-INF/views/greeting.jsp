<%--
    =============================================
    WHAT IS A JSP?
    =============================================
    JSP (JavaServer Pages) is an HTML file that can contain
    dynamic Java content. Tomcat compiles it into a Servlet
    behind the scenes.

    The JSP is the VIEW — it's what you see in the browser.
    The Servlet (controller) prepares the data,
    the JSP (view) displays it.

    =============================================
    KEY CONCEPTS IN THIS FILE
    =============================================
    1. Taglib directive — imports JSTL tag libraries
    2. EL (Expression Language) — ${variable} syntax to display data
    3. JSTL <c:if> — conditional rendering (show/hide sections)
    4. JSTL <c:out> — XSS-safe output of user data
    5. Form action — tells the browser WHERE to send form data
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- This imports the JSTL Core library so we can use <c:if>, <c:out>, etc. --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <title>Greeting Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
        }
        .greeting-box {
            background: #e8f5e9;
            border: 2px solid #4caf50;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            font-size: 1.2em;
        }
        form {
            margin: 20px 0;
        }
        input[type="text"] {
            padding: 8px 12px;
            font-size: 1em;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 250px;
        }
        button {
            padding: 8px 20px;
            font-size: 1em;
            background: #1976d2;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background: #1565c0;
        }
        .flow-diagram {
            background: #f5f5f5;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            font-family: monospace;
            font-size: 0.9em;
            line-height: 1.8;
        }
    </style>
</head>

<body>
    <h1>Greeting Demo</h1>

    <%--
        =============================================
        THE FORM
        =============================================
        action="${pageContext.request.contextPath}/greeting"
          — sends the form data to the GreetingServlet

        method="post"
          — uses POST method, so Tomcat calls doPost()
          — if it used method="get", Tomcat would call doGet()

        name="name"
          — this is the key used in the Servlet:
            request.getParameter("name")
    --%>
    <form action="${pageContext.request.contextPath}/greeting" method="post">
        <label for="name">Enter your name:</label><br /><br />
        <input type="text" id="name" name="name" placeholder="e.g. Sandesh" required />
        <button type="submit">Greet Me</button>
    </form>

    <%--
        =============================================
        CONDITIONAL DISPLAY WITH <c:if>
        =============================================
        ${name} refers to the request attribute set in the Servlet:
            request.setAttribute("name", name);

        <c:if test="${not empty name}"> means:
            "Only show this section if 'name' is not null and not blank"

        Without <c:if>, this section would always show — even on the
        first visit when there's no name yet.
    --%>
    <c:if test="${not empty name}">
        <div class="greeting-box">
            <%--
                <c:out> displays the value with HTML escaping (XSS protection).
                If someone typed <script>alert('hack')</script> as their name:
                  - ${name} would EXECUTE the script (dangerous!)
                  - <c:out value="${name}"> would DISPLAY it as text (safe!)

                Always use <c:out> when displaying user-provided data.
            --%>
            Hello, <c:out value="${name}" />! Welcome to the APT Extra Class.
        </div>
    </c:if>

    <hr />

    <h3>How This Works (MVC Flow)</h3>
    <div class="flow-diagram">
        <strong>First visit (GET request):</strong><br />
        Browser --GET /greeting--> GreetingServlet.doGet() --forward--> greeting.jsp<br />
        (form is empty, no greeting shown)<br /><br />

        <strong>Form submit (POST request):</strong><br />
        Browser --POST /greeting (name=Sandesh)--> GreetingServlet.doPost()<br />
        &nbsp;&nbsp;1. reads: request.getParameter("name") -> "Sandesh"<br />
        &nbsp;&nbsp;2. sets:  request.setAttribute("name", "Sandesh")<br />
        &nbsp;&nbsp;3. forwards to greeting.jsp<br />
        greeting.jsp displays: "Hello, Sandesh!"
    </div>

    <h3>Dependencies We Need</h3>
    <div class="flow-diagram">
        1. <strong>jakarta.servlet-api</strong> (provided) — Servlet classes (HttpServlet, @WebServlet)<br />
        2. <strong>jakarta.servlet.jsp-api</strong> (provided) — Lets Tomcat compile .jsp files<br />
        3. <strong>jakarta.servlet.jsp.jstl-api</strong> — JSTL tags (&lt;c:if&gt;, &lt;c:out&gt;)<br />
        4. <strong>jakarta.servlet.jsp.jstl</strong> (impl) — Runs the JSTL tags at runtime<br /><br />
        "provided" = Tomcat already has it, don't include in WAR<br />
        (no scope) = Include in WAR, Tomcat doesn't have it
    </div>
</body>
</html>
