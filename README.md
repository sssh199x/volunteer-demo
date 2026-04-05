# Volunteer Demo — JSP & Servlet Basics

A minimal web app to introduce APT extra-class volunteers to how our student projects work.

## Prerequisites

Before running this project, you need two things installed:

1. **Java JDK 25** — the Java compiler and runtime
2. **Apache Maven** — the build tool that manages dependencies and compiles the project

See **[SETUP.md](SETUP.md)** for detailed installation steps for both Windows and Mac.

You do **NOT** need to install Tomcat — the Cargo Maven plugin downloads it automatically.

### Why Cargo instead of Smart Tomcat?

There are two ways to run Tomcat in this course:

| | Cargo (what we use) | Smart Tomcat (alternative) |
|---|---|---|
| **Setup** | Zero — just run `mvn clean package cargo:run` | Install the IntelliJ plugin + download Tomcat manually + configure a run configuration |
| **Tomcat version** | Everyone gets the exact same version (10.1.34) | Each person might use a different version |
| **IDE** | Works from any terminal — IntelliJ, VS Code, or plain command line | IntelliJ only |
| **Debugging** | Requires extra JVM flags | Just click the Debug button |

**We chose Cargo because:**
- One command works for everyone — no per-student setup issues
- Students don't need IntelliJ specifically (some may use VS Code or terminal)
- Everyone runs the exact same Tomcat version, so fewer "works on my machine" problems
- No need to download or configure Tomcat manually

**Smart Tomcat is still a good option** if you prefer IntelliJ's Debug button. It can work alongside Cargo — the pom.xml doesn't need to change. You'd just need to:
1. Install the Smart Tomcat plugin in IntelliJ (Settings → Plugins)
2. Download Tomcat 10.1.x and extract it somewhere
3. Create a run configuration: Run → Edit Configurations → + → Smart Tomcat → set Tomcat path, context path `/demo`, port `9090`

---

**Run it:**
```bash
mvn clean package cargo:run
```
Then visit: [http://localhost:9090/demo/greeting](http://localhost:9090/demo/greeting)

---

## Session Guide

### 1. Project Structure (5 min)

Before opening any code, show the folder layout:

```
volunteer-demo/
├── pom.xml                                  ← dependencies & build config
├── src/main/java/com/demo/
│   └── GreetingServlet.java                 ← the CONTROLLER (handles requests)
└── src/main/webapp/WEB-INF/views/
    └── greeting.jsp                         ← the VIEW (what the user sees)
```

Key points to explain:
- **`pom.xml`** — Maven config file. Lists what libraries (dependencies) the project needs. Maven downloads them automatically.
- **`src/main/java/`** — where Java code lives (Servlets, DAOs, models).
- **`src/main/webapp/WEB-INF/views/`** — where JSP pages live. Files inside `WEB-INF` are **hidden** from direct browser access — users must go through a Servlet first.
- **`target/`** — generated folder (the compiled `.war` file goes here). Never edit anything in `target/`.

---

### 2. Dependencies in pom.xml (5 min)

Open `pom.xml` and walk through each dependency. Focus on **why** we need each one:

| # | Dependency | What It Does | Scope |
|---|-----------|-------------|-------|
| 1 | `jakarta.servlet-api` | Lets us write Servlets (`@WebServlet`, `HttpServlet`, `doGet`, `doPost`) | `provided` — Tomcat already has it |
| 2 | `jakarta.servlet.jsp-api` | Lets Tomcat compile `.jsp` files into Java | `provided` — Tomcat already has it |
| 3 | `jakarta.servlet.jsp.jstl-api` | JSTL tags: `<c:if>`, `<c:forEach>`, `<c:out>` | included in WAR |
| 4 | `jakarta.servlet.jsp.jstl` (impl) | The code that actually **runs** those JSTL tags | included in WAR |

**"provided" means:** Tomcat already includes this library, so don't put it in the WAR file. We only need it during compilation.


---

### 3. The Servlet — GreetingServlet.java (10 min)

Open `src/main/java/com/demo/GreetingServlet.java`.

#### What is a Servlet?
A Java class that handles HTTP requests. When someone visits a URL, Tomcat calls the matching method:
- **GET request** (typing a URL, clicking a link) → `doGet()`
- **POST request** (submitting a form) → `doPost()`

#### Walk through the code:

**`@WebServlet("/greeting")`**
- This annotation maps the URL `/greeting` to this class.
- Without it, Tomcat wouldn't know which Servlet handles which URL.

**`doGet()`** — First visit
```
User visits /demo/greeting
  → Tomcat calls doGet()
    → Forwards to greeting.jsp (shows empty form)
```

**`doPost()`** — Form submission
```
User submits form with name="Sandesh"
  → Tomcat calls doPost()
    → request.getParameter("name") reads "Sandesh" from the form
    → request.setAttribute("name", "Sandesh") puts it in the request
    → Forwards to greeting.jsp (now ${name} = "Sandesh")
```

**Key concept — `request.setAttribute()` is how data flows from Servlet to JSP:**
- Servlet sets: `request.setAttribute("name", "Sandesh")`
- JSP reads: `${name}`
- The attribute name must match — `"name"` in Java = `${name}` in JSP.

---

### 4. The JSP — greeting.jsp (10 min)

Open `src/main/webapp/WEB-INF/views/greeting.jsp`.

#### What is a JSP?
An HTML file with special tags that can display dynamic data. Tomcat compiles it into a Servlet behind the scenes — but we write it as HTML, which is much easier.

#### Walk through the key parts:

**Taglib directive (line 1 of actual HTML):**
```jsp
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
```
- This imports the JSTL Core library so we can use `<c:if>`, `<c:out>`, etc.
- Without this line, those tags won't work.

**The form:**
```jsp
<form action="${pageContext.request.contextPath}/greeting" method="post">
    <input type="text" name="name" />
    <button type="submit">Greet Me</button>
</form>
```
- `action="..."` — WHERE to send the data (our Servlet URL).
- `method="post"` — Tomcat will call `doPost()`.
- `name="name"` — this key is what `request.getParameter("name")` reads in the Servlet.

**Conditional display with `<c:if>`:**
```jsp
<c:if test="${not empty name}">
    Hello, <c:out value="${name}" />!
</c:if>
```
- `${not empty name}` — only show this if `name` is not null/blank.
- On first visit (GET), no `name` attribute exists → greeting is hidden.
- After form submit (POST), `name` is set → greeting is shown.

**XSS protection with `<c:out>`:**
```jsp
<c:out value="${name}" />     ← SAFE: escapes HTML
${name}                       ← DANGEROUS: renders raw HTML
```

**Demo XSS:** Type `<script>alert('hacked')</script>` as the name.
- With `<c:out>`: displays as text (safe).
- Explain: if we used raw `${name}`, the browser would execute the script.

---

### 5. Run It Together (5 min)

```bash
mvn clean package cargo:run
```

What this command does:
1. `clean` — deletes the `target/` folder (fresh build)
2. `package` — compiles Java code, packages into a `.war` file
3. `cargo:run` — downloads Tomcat (first time only), deploys the WAR, starts server

Visit: [http://localhost:9090/demo/greeting](http://localhost:9090/demo/greeting)

**Live walkthrough:**
1. Show the empty form (this is a GET request → `doGet()`)
2. Type a name, click submit (this is a POST request → `doPost()`)
3. Show the greeting appears
4. Try the XSS demo: type `<script>alert('hacked')</script>` — it shows as text, not executed

Stop the server: press `Ctrl+C` in the terminal.

---

### 6. The MVC Pattern — Putting It All Together (2 min)

```
         REQUEST                    DATA                     RESPONSE
Browser ---------> Servlet ----setAttribute----> JSP ---------> Browser
                  (Controller)                  (View)
                  Java code                     HTML + EL/JSTL
```

- **Model** — the data (`name = "Sandesh"`)
- **View** — the JSP page (displays the data as HTML)
- **Controller** — the Servlet (receives request, prepares data, picks which view to show)

Students will be building apps that follow this exact pattern, with more servlets, more JSPs, and a database layer (DAO) for storing data.

---

## Quick Reference for Volunteers

| Concept | What It Is | Example |
|---------|-----------|---------|
| Servlet | Java class that handles HTTP requests | `GreetingServlet.java` |
| JSP | HTML page with dynamic content | `greeting.jsp` |
| EL | Expression Language — `${variable}` | `${name}` |
| JSTL | Tag library for logic in JSP | `<c:if>`, `<c:out>` |
| `doGet()` | Handles GET requests (page load, links) | Showing the form |
| `doPost()` | Handles POST requests (form submit) | Processing the name |
| `setAttribute()` | Passes data from Servlet to JSP | `request.setAttribute("name", value)` |
| `getParameter()` | Reads form input in Servlet | `request.getParameter("name")` |
| `forward()` | Sends the request to a JSP | `dispatcher.forward(request, response)` |
| `WEB-INF` | Protected folder — no direct browser access | `/WEB-INF/views/greeting.jsp` |
| `provided` scope | Tomcat has it — don't include in WAR | `jakarta.servlet-api` |
| `<c:out>` | XSS-safe output | `<c:out value="${name}" />` |
