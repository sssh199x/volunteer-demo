# Setup Guide — Java JDK & Maven Installation

## 1. Java JDK 25

The Java compiler and runtime — needed to compile and run all Java code.

### Windows

1. Go to [https://www.oracle.com/java/technologies/downloads/](https://www.oracle.com/java/technologies/downloads/)
2. Under Java 25, click the **Windows** tab
3. Download the **x64 Installer** (.exe)
4. Run the installer — click Next through the steps, note the install path (usually `C:\Program Files\Java\jdk-25`)
5. **Set JAVA_HOME environment variable:**
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Go to **Advanced** tab → **Environment Variables**
   - Under **System variables**, click **New**:
     - Variable name: `JAVA_HOME`
     - Variable value: `C:\Program Files\Java\jdk-25`
   - Find the **Path** variable in System variables → click **Edit** → click **New** → add:
     ```
     %JAVA_HOME%\bin
     ```
   - Click OK on all dialogs
6. **Verify:** Open a **new** Command Prompt (old ones won't see the change) and run:
   ```
   java --version
   ```
   Should show `java 25` or similar.

### Mac

1. Go to [https://www.oracle.com/java/technologies/downloads/](https://www.oracle.com/java/technologies/downloads/)
2. Under Java 25, click the **macOS** tab
3. Download the **ARM64 DMG Installer** (for Apple Silicon M1/M2/M3/M4) or **x64 DMG Installer** (for older Intel Macs)
4. Open the .dmg file and run the .pkg installer — follow the steps
5. The installer automatically sets everything up. No manual PATH config needed on Mac.
6. **Verify:** Open Terminal and run:
   ```
   java --version
   ```
   Should show `java 25` or similar.

---

## 2. Apache Maven

The build tool that manages dependencies, compiles the project, and packages it into a WAR file.

### Windows

1. Go to [https://maven.apache.org/download.cgi](https://maven.apache.org/download.cgi)
2. Download the **Binary zip archive** (`apache-maven-3.x.x-bin.zip`)
3. Extract the zip to a permanent location, e.g., `C:\Program Files\Apache\maven`
   - You should see a folder like `C:\Program Files\Apache\maven\apache-maven-3.9.9`
4. **Set MAVEN_HOME and update Path:**
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Go to **Advanced** tab → **Environment Variables**
   - Under **System variables**, click **New**:
     - Variable name: `MAVEN_HOME`
     - Variable value: `C:\Program Files\Apache\maven\apache-maven-3.9.9`
   - Find the **Path** variable in System variables → click **Edit** → click **New** → add:
     ```
     %MAVEN_HOME%\bin
     ```
   - Click OK on all dialogs
5. **Verify:** Open a **new** Command Prompt and run:
   ```
   mvn --version
   ```
   Should show Maven 3.x.x and the JDK 25 path. If it shows a different Java version, check that JAVA_HOME is set correctly.

### Mac

**Option A — Homebrew (recommended if you have Homebrew):**
```bash
brew install maven
```
Done. Homebrew handles everything.

**Option B — Manual install:**

1. Go to [https://maven.apache.org/download.cgi](https://maven.apache.org/download.cgi)
2. Download the **Binary zip archive** (`apache-maven-3.x.x-bin.zip`)
3. Extract it to a location like `~/maven`:
   ```bash
   mkdir -p ~/maven
   unzip apache-maven-3.9.9-bin.zip -d ~/maven
   ```
4. Add to your shell profile (`~/.zshrc` for macOS):
   ```bash
   export MAVEN_HOME=~/maven/apache-maven-3.9.9
   export PATH=$MAVEN_HOME/bin:$PATH
   ```
5. Reload the profile:
   ```bash
   source ~/.zshrc
   ```

**Verify:**
```bash
mvn --version
```
Should show Maven 3.x.x and the JDK 25 path.

---

## 3. Verify Both Are Working

Open a new terminal/command prompt and run both:

```bash
java --version
mvn --version
```

You should see something like:
```
java 25 2025-09-16
Java(TM) SE Runtime Environment (build 25+...)

Apache Maven 3.9.9
Maven home: /path/to/maven
Java version: 25, vendor: Oracle Corporation
```

If `mvn --version` shows a different Java version than 25, your `JAVA_HOME` is pointing to the wrong JDK. Update it to point to the JDK 25 installation path.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `java` is not recognized | JAVA_HOME not set or `%JAVA_HOME%\bin` not in Path. Restart your terminal after setting it. |
| `mvn` is not recognized | MAVEN_HOME not set or `%MAVEN_HOME%\bin` not in Path. Restart your terminal after setting it. |
| `mvn --version` shows wrong Java | JAVA_HOME is pointing to an older JDK. Update it to the JDK 25 path. |
| Mac: `brew` not found | Install Homebrew first: visit [https://brew.sh](https://brew.sh) and run the install command. |
| Windows: changes not taking effect | You must open a **new** Command Prompt after changing environment variables. Old windows keep the old values. |
