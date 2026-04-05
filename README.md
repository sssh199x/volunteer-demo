# Volunteer Demo — JSP & Servlet Basics

A minimal web app to help you understand how the student projects in APT extra classes work.

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

## Running the App

```bash
mvn clean package cargo:run
```
Then visit: [http://localhost:9090/demo/greeting](http://localhost:9090/demo/greeting)

To stop the server, press `Ctrl+C` in the terminal.

---

## 1. Project Structure

Here's what's inside this project:

```
volunteer-demo/
├── pom.xml                                  ← dependencies & build config
├── src/main/java/com/demo/
│   └── GreetingServlet.java                 ← the CONTROLLER (handles requests)
└── src/main/webapp/WEB-INF/views/
    └── greeting.jsp                         ← the VIEW (what the user sees)
```

- **`pom.xml`** — Maven config file. Lists what libraries (dependencies) the project needs. Maven downloads them automatically.
- **`src/main/java/`** — where Java code lives (Servlets, DAOs, models).
- **`src/main/webapp/WEB-INF/views/`** — where JSP pages live. Files inside `WEB-INF` are **hidden** from direct browser access — you must go through a Servlet first.
- **`target/`** — generated folder (the compiled `.war` file goes here). Never edit anything in `target/`.

---

## 2. Dependencies in pom.xml

Open `pom.xml` and look at the dependencies. Each one serves a specific purpose:

| # | Dependency | What It Does | Scope |
|---|-----------|-------------|-------|
| 1 | `jakarta.servlet-api` | Lets us write Servlets (`@WebServlet`, `HttpServlet`, `doGet`, `doPost`) | `provided` — Tomcat already has it |
| 2 | `jakarta.servlet.jsp-api` | Lets Tomcat compile `.jsp` files into Java | `provided` — Tomcat already has it |
| 3 | `jakarta.servlet.jsp.jstl-api` | JSTL tags: `<c:if>`, `<c:forEach>`, `<c:out>` | included in WAR |
| 4 | `jakarta.servlet.jsp.jstl` (impl) | The code that actually **runs** those JSTL tags | included in WAR |

**"provided" means:** Tomcat already includes this library, so we don't put it in the WAR file. We only need it during compilation.

---

## 3. The Servlet — GreetingServlet.java

Open `src/main/java/com/demo/GreetingServlet.java`.

### What is a Servlet?

A Servlet is a Java class that handles HTTP requests. When someone visits a URL, Tomcat calls the matching method:
- **GET request** (typing a URL, clicking a link) → `doGet()`
- **POST request** (submitting a form) → `doPost()`

### Key parts of the code:

**`@WebServlet("/greeting")`**
- This annotation maps the URL `/greeting` to this class.
- Without it, Tomcat wouldn't know which Servlet handles which URL.

**`doGet()`** — what happens when you first visit the page:
```
You visit /demo/greeting
  → Tomcat calls doGet()
    → Forwards to greeting.jsp (shows the empty form)
```

**`doPost()`** — what happens when you submit the form:
```
You submit the form with name="Sandesh"
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

## 4. The JSP — greeting.jsp

Open `src/main/webapp/WEB-INF/views/greeting.jsp`.

### What is a JSP?

A JSP (JavaServer Pages) is an HTML file with special tags that can display dynamic data. Tomcat compiles it into a Servlet behind the scenes — but you write it as HTML, which is much easier.

### Key parts of the file:

**Taglib directive:**
```jsp
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
```
- This imports the JSTL Core library so you can use `<c:if>`, `<c:out>`, etc.
- Without this line, those tags won't work.

**The form:**
```jsp
<form action="${pageContext.request.contextPath}/greeting" method="post">
    <input type="text" name="name" />
    <button type="submit">Greet Me</button>
</form>
```
- `action="..."` — WHERE to send the data (the Servlet URL).
- `method="post"` — Tomcat will call `doPost()`.
- `name="name"` — this key is what `request.getParameter("name")` reads in the Servlet.

**Conditional display with `<c:if>`:**
```jsp
<c:if test="${not empty name}">
    Hello, <c:out value="${name}" />!
</c:if>
```
- `${not empty name}` — only shows this section if `name` is not null/blank.
- On first visit (GET), no `name` attribute exists → the greeting is hidden.
- After form submit (POST), `name` is set → the greeting appears.

**XSS protection with `<c:out>`:**
```jsp
<c:out value="${name}" />     ← SAFE: escapes HTML
${name}                       ← DANGEROUS: renders raw HTML
```

**Try it yourself:** Type `<script>alert('hacked')</script>` as the name and submit.
- With `<c:out>`: it displays as text (safe).
- If we used raw `${name}`, the browser would execute that script — that's an XSS attack.

---

## 5. Running the App

```bash
mvn clean package cargo:run
```

What this command does:
1. `clean` — deletes the `target/` folder (fresh build)
2. `package` — compiles Java code, packages into a `.war` file
3. `cargo:run` — downloads Tomcat (first time only), deploys the WAR, starts the server

Visit: [http://localhost:9090/demo/greeting](http://localhost:9090/demo/greeting)

**Try these steps:**
1. You'll see the empty form — this is a GET request, which triggered `doGet()`
2. Type a name and click submit — this is a POST request, which triggers `doPost()`
3. The greeting appears with your name
4. Try the XSS test: type `<script>alert('hacked')</script>` — it displays as text, not executed

To stop the server, press `Ctrl+C` in the terminal.

---

## 6. The MVC Pattern — How It All Connects

```
         REQUEST                    DATA                     RESPONSE
Browser ---------> Servlet ----setAttribute----> JSP ---------> Browser
                  (Controller)                  (View)
                  Java code                     HTML + EL/JSTL
```

- **Model** — the data (`name = "Sandesh"`)
- **View** — the JSP page (displays the data as HTML)
- **Controller** — the Servlet (receives the request, prepares data, picks which view to show)

In the student projects, you'll see this same pattern but with more servlets, more JSPs, and a database layer (DAO) for storing data.

---

## Frequently Asked Questions

**Q: Where is `web.xml`? Don't we need it?**

In older Java web projects, `web.xml` was required — it mapped URLs to Servlets and configured the app. But since Servlet 3.0+, we can use **annotations** instead. The `@WebServlet("/greeting")` annotation on our Servlet does the same job as a `web.xml` mapping. So we don't need a `web.xml` at all for this project. In the student projects, you might see `web.xml` used for things like error pages (e.g., custom 404 pages), but for basic servlet mapping, annotations are simpler and preferred.

**Q: Why is there no welcome/index page? What happens if I visit `http://localhost:9090/demo/`?**

You'll get a 404 error because there's no `index.html`, `index.jsp`, or welcome file configured. This is intentional — in this demo, you go directly to `http://localhost:9090/demo/greeting`. In the student projects, there's usually a servlet mapped to `/` or a welcome file that redirects to the main page.

**Q: Why `jakarta.*` instead of `javax.*`?**

In 2017, Java EE was transferred from Oracle to the Eclipse Foundation and renamed to **Jakarta EE**. The package names changed from `javax.servlet` to `jakarta.servlet`. Since we use Tomcat 10+ (which implements Jakarta EE), we use `jakarta.*`. If you see `javax.*` in older tutorials or the lecturer's slides, that's the old naming — don't mix them.

**Q: Can we put JSP files outside `WEB-INF`?**

Yes, and they'd be accessible directly in the browser (e.g., `http://localhost:9090/demo/greeting.jsp`). But that **bypasses the Servlet** — meaning no data gets prepared, no security checks happen. Putting JSPs inside `WEB-INF` forces all requests through a Servlet first, which is the proper MVC pattern.

**Q: What's the difference between `forward` and `redirect`?**

- **Forward** (`request.getRequestDispatcher(...).forward(...)`) — happens **server-side**. The browser doesn't know it happened. The URL stays the same. The request attributes (`${name}`) are preserved.
- **Redirect** (`response.sendRedirect(...)`) — tells the **browser** to make a new request. The URL changes. Request attributes are lost (new request).

In this demo, we use forward because we need `${name}` to reach the JSP. In the student projects, redirects are used after form submissions (POST → redirect → GET pattern) to prevent duplicate submissions on refresh.

**Q: What's a WAR file?**

WAR stands for **Web Application Archive**. It's a `.zip` file with a `.war` extension that contains everything needed to run the web app: compiled Java classes, JSP files, CSS/JS, and libraries. When you run `mvn package`, Maven creates `target/volunteer-demo-1.0-SNAPSHOT.war`. Cargo takes that WAR and deploys it into Tomcat.

**Q: Why do we need both JSTL API and JSTL Implementation?**

The **API** (`jakarta.servlet.jsp.jstl-api`) defines what the tags are — like an interface. The **Implementation** (`jakarta.servlet.jsp.jstl` from Glassfish) is the actual code that runs the tags. Without the API, your JSP wouldn't compile. Without the implementation, the tags would compile but fail at runtime. You always need both.

---

## Quick Reference

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
