# 🚀 Jenkins CI/CD Pipeline — Complete Beginner's Guide

> **Spring PetClinic → AWS Secrets Manager → Build → Test → SonarQube → Quality Gate → JFrog**

This guide explains every single step of a Jenkins declarative pipeline from scratch.
Written so you can come back anytime and understand exactly what every line means.

---

## 📖 Table of Contents

1. [What is CI/CD and Why Do We Need It?](#1-what-is-cicd-and-why-do-we-need-it)
2. [Tools Used and What Each One Does](#2-tools-used-and-what-each-one-does)
3. [Infrastructure Setup](#3-infrastructure-setup)
4. [What is a Jenkinsfile?](#4-what-is-a-jenkinsfile)
5. [Pipeline Skeleton — Every Keyword Explained](#5-pipeline-skeleton--every-keyword-explained)
6. [Stage 1 — AWS Secrets Manager](#6-stage-1--aws-secrets-manager)
7. [Stage 2 — Checkout Code](#7-stage-2--checkout-code)
8. [Stage 3 — Build and Test (JUnit)](#8-stage-3--build-and-test-junit)
9. [Stage 4 — SonarQube Analysis](#9-stage-4--sonarqube-analysis)
10. [Stage 5 — Quality Gate](#10-stage-5--quality-gate)
11. [Stage 6 — Upload to JFrog Artifactory](#11-stage-6--upload-to-jfrog-artifactory)
12. [Complete Jenkinsfile](#12-complete-jenkinsfile)
13. [What is -D in Maven Commands?](#13-what-is--d-in-maven-commands)
14. [Jenkins Plugin Setup](#14-jenkins-plugin-setup)
15. [Troubleshooting Guide](#15-troubleshooting-guide)

---

## 1. What is CI/CD and Why Do We Need It?

### The Old Way (Without CI/CD)

```
Developer writes code
        ↓
Manually compiles on their laptop
        ↓
Manually runs tests (or skips them!)
        ↓
Manually copies the file to server
        ↓
Something breaks in production
        ↓
Nobody knows why 😱
```

### The New Way (With CI/CD)

```
Developer pushes code to Git
        ↓
Jenkins automatically wakes up
        ↓
Automatically builds the code
        ↓
Automatically runs all tests
        ↓
Automatically checks code quality
        ↓
Automatically stores the artifact
        ↓
Everyone can see what happened and why ✅
```

### Real Life Analogy

Think of CI/CD like a **car assembly line**:
- Each station does ONE specific job
- If one station fails, the line STOPS — broken cars never reach customers
- Everything is automatic, consistent and trackable
- Jenkins is the **factory manager** who controls the whole line

---

## 2. Tools Used and What Each One Does

```
┌─────────────────────────────────────────────────────────────────────┐
│                        YOUR CI/CD PIPELINE                          │
├─────────────────┬───────────────────────────────────────────────────┤
│ Tool            │ What it does (in plain English)                   │
├─────────────────┼───────────────────────────────────────────────────┤
│ Jenkins         │ The BOSS — orchestrates everything                │
│                 │ Reads Jenkinsfile and runs each stage             │
├─────────────────┼───────────────────────────────────────────────────┤
│ Maven           │ The BUILDER — compiles Java code                  │
│                 │ Runs tests, creates the JAR file                  │
├─────────────────┼───────────────────────────────────────────────────┤
│ AWS Secrets     │ The VAULT — stores passwords safely               │
│ Manager         │ Jenkins fetches secrets at runtime                │
├─────────────────┼───────────────────────────────────────────────────┤
│ SonarQube       │ The REVIEWER — scans code for bugs,               │
│                 │ vulnerabilities, code smells                      │
├─────────────────┼───────────────────────────────────────────────────┤
│ Quality Gate    │ The BOUNCER — blocks bad code from proceeding     │
│                 │ Pass = continue. Fail = pipeline stops            │
├─────────────────┼───────────────────────────────────────────────────┤
│ JFrog           │ The WAREHOUSE — stores final built JAR files      │
│ Artifactory     │ Versioned, secure, accessible by all teams        │
├─────────────────┼───────────────────────────────────────────────────┤
│ JUnit           │ The TESTER — runs unit tests automatically        │
│                 │ Results shown as graphs in Jenkins dashboard      │
└─────────────────┴───────────────────────────────────────────────────┘
```

---

## 3. Infrastructure Setup

### Access URLs (from the setup script)

| Tool | URL | Default Login |
|------|-----|---------------|
| Jenkins | `http://<server-ip>:8095` | See initial password below |
| SonarQube | `http://<server-ip>:32000` | admin / admin |
| JFrog | `http://<server-ip>:30465` | admin / password |

### Get Jenkins Initial Password

```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Pipeline Full Flow Diagram

```
                        ┌─────────────────────────────────────┐
                        │           JENKINS PIPELINE           │
                        └─────────────────────────────────────┘
                                          │
              ┌───────────────────────────▼───────────────────────────┐
              │                                                         │
              ▼                                                         │
   ┌──────────────────┐                                                 │
   │  AWS Secrets Mgr │  ← Fetch DB credentials securely               │
   └────────┬─────────┘                                                 │
            │ DB_URL, DB_USER, DB_PASS                                  │
            ▼                                                           │
   ┌──────────────────┐                                                 │
   │  Checkout Code   │  ← Clone Spring PetClinic from GitHub          │
   └────────┬─────────┘                                                 │
            │                                                           │
            ▼                                                           │
   ┌──────────────────┐                                                 │
   │  Build & Test    │  ← mvn clean package + JUnit tests             │
   │  (JUnit results) │                                                 │
   └────────┬─────────┘                                                 │
            │                                                           │
            ▼                                                           │
   ┌──────────────────┐                                                 │
   │ SonarQube Scan   │  ← Analyse code quality                        │
   └────────┬─────────┘                                                 │
            │                                                           │
            ▼                                                           │
   ┌──────────────────┐                                                 │
   │  Quality Gate    │  ← PASS → continue │ FAIL → abort pipeline     │
   └────────┬─────────┘                                                 │
            │ (only if PASS)                                            │
            ▼                                                           │
   ┌──────────────────┐                                                 │
   │  Upload to JFrog │  ← Store JAR file in Artifactory               │
   └──────────────────┘                                                 │
                                                                        │
              └───────────────────────────────────────────────────────┘
```

---

## 4. What is a Jenkinsfile?

A Jenkinsfile is a **text file** that lives in your project's root folder (same place as `pom.xml`).

It tells Jenkins exactly:
- What stages to run
- What commands to execute in each stage
- What to do if something fails

### Real Life Analogy

Think of it like a **recipe card**:
- The recipe card = Jenkinsfile
- The chef = Jenkins
- Each cooking step = a stage in the pipeline
- If one step fails (dough doesn't rise) → chef stops and reports the problem

### Where to Put the Jenkinsfile

```
spring-petclinic/           ← your project root
├── Jenkinsfile             ← Jenkins reads this automatically
├── pom.xml                 ← Maven config
├── src/
│   ├── main/java/          ← your Java code
│   └── test/java/          ← your test code
└── target/                 ← Maven puts compiled code here
```

---

## 5. Pipeline Skeleton — Every Keyword Explained

```groovy
pipeline {
//  ↑
//  This keyword tells Jenkins:
//  "Everything inside these curly braces is a Jenkins pipeline"
//  Always the outermost wrapper. Required.

    agent any
//  ↑     ↑
//  agent = WHERE should this pipeline run?
//  any   = run on any available Jenkins agent/executor
//  Other options:
//    agent none          → stages will define their own agents
//    agent { label 'linux' } → run only on nodes labelled 'linux'

    tools {
//  ↑
//  Tells Jenkins WHICH tools to use
//  These must be configured in Jenkins → Manage Jenkins → Tools

        maven 'Maven'
//              ↑ must match the name you gave in Global Tool Configuration

        jdk 'Java11'
//          ↑ Spring PetClinic needs Java 11
    }

    environment {
//  ↑
//  Define variables available to ALL stages
//  Like global variables for the entire pipeline
//  Access them with: ${VARIABLE_NAME} or ${env.VARIABLE_NAME}

        APP_NAME    = 'spring-petclinic'
        APP_VERSION = '3.3.0'
        AWS_REGION  = 'ap-south-1'
    }

    stages {
//  ↑
//  The container that holds ALL your stages
//  Stages run in the ORDER you define them (top to bottom)

        stage('My Stage Name') {
//      ↑      ↑
//      stage  = one step/phase in your pipeline
//      name   = displayed in Jenkins UI — use descriptive names

            steps {
//          ↑
//          The actual COMMANDS to run inside this stage
//          This is where real work happens

                sh 'echo Hello'
//              ↑  ↑
//              sh = run a shell (bash) command
//              everything in quotes is a bash command

                echo 'This is a Jenkins message'
//              ↑
//              echo = print a message in Jenkins console log
            }
        }
    }

    post {
//  ↑
//  Runs AFTER all stages finish — regardless of success or failure
//  Good place for cleanup, notifications, final reports

        success {
            echo 'Pipeline passed!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            cleanWs()
//          ↑ delete workspace files to free disk space
        }
    }
}
```

---

## 6. Stage 1 — AWS Secrets Manager

### What is AWS Secrets Manager?

It is a **secure vault** provided by Amazon Web Services that stores sensitive information like:
- Database passwords
- API keys
- Connection strings
- Any value you don't want hardcoded in code

### Why Not Just Put Passwords in the Code?

```
❌ BAD — Hardcoded in Jenkinsfile:
    -Dspring.datasource.password=MySecret123

    Problems:
    → Anyone who reads the code sees the password
    → Password is saved forever in Git history
    → To change password you must edit code
    → Security audit fails

✅ GOOD — Fetched from AWS Secrets Manager:
    → Password stored encrypted in AWS
    → Only Jenkins (with correct IAM permission) can read it
    → Change password in AWS once → everywhere auto-updated
    → Code has no sensitive data
```

### How Jenkins Authenticates with AWS

Your setup script already handled this by copying AWS credentials to Jenkins:

```bash
# Your script does this automatically:
cp ~/.aws/credentials  /var/lib/jenkins/.aws/credentials
cp ~/.aws/config       /var/lib/jenkins/.aws/config
chown -R jenkins:jenkins /var/lib/jenkins/.aws
```

The credentials file looks like:

```ini
[default]
aws_access_key_id     = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENGbPxRfiCYEXAMPLEKEY
```

This is like Jenkins having an **ID card** — when it talks to AWS, AWS knows who it is.

### What the Secret Looks Like in AWS

Go to: AWS Console → Secrets Manager → Store a new secret

Store it as a **JSON key-value pair**:

```json
{
  "DB_URL":      "jdbc:mysql://localhost:3306/petclinic",
  "DB_USERNAME": "petclinic_user",
  "DB_PASSWORD": "YourSecurePassword123!"
}
```

Name the secret: `petclinic/db`

### Flow Diagram

```
Developer                AWS IAM              AWS Secrets Manager
    │                      │                         │
    │  (stored credentials │                         │
    │   in Jenkins server) │                         │
    │                      │                         │
Jenkins ──── "Who am I?" ──▶ IAM checks credentials  │
    │                      │                         │
    │         ◀── "Allowed"│                         │
    │                      │                         │
    │ ────── "Give me petclinic/db secret" ──────────▶
    │                      │                         │
    │ ◀────── Returns JSON { DB_URL, DB_PASS, ... } ──
    │                      │                         │
    │  Stores as env vars                            │
    │  (available to all later stages)               │
```

### The Code — Line by Line

```groovy
stage('Get Secrets from AWS') {
    steps {
        script {

            // sh() runs a shell command
            // returnStdout: true captures what the command prints
            // .trim() removes any trailing newline characters
            def secret = sh(
                script: """
                    aws secretsmanager get-secret-value \
                    --secret-id petclinic/db \
                    --region ap-south-1 \
                    --query SecretString \
                    --output text
                """,
                //  aws secretsmanager get-secret-value
                //  ↑ AWS CLI command to fetch a secret
                //
                //  --secret-id petclinic/db
                //  ↑ The NAME you gave to your secret in AWS
                //
                //  --region ap-south-1
                //  ↑ Which AWS region your secret is in
                //    change this to your actual region
                //
                //  --query SecretString
                //  ↑ AWS returns a big JSON object
                //    this filters ONLY the "SecretString" field
                //    which contains your actual secret JSON
                //
                //  --output text
                //  ↑ Return as plain text (not wrapped in extra JSON)

                returnStdout: true
            ).trim()

            // At this point 'secret' variable contains:
            // {"DB_URL":"jdbc:mysql://...","DB_USERNAME":"user","DB_PASSWORD":"pass"}

            // readJSON parses a JSON string into a Groovy object
            // Now you can access fields with dot notation
            def jsonSecret = readJSON text: secret

            // env.VARIABLE = value makes it a pipeline environment variable
            // Available to ALL stages that run after this
            env.DB_URL      = jsonSecret.DB_URL
            env.DB_USERNAME = jsonSecret.DB_USERNAME
            env.DB_PASSWORD = jsonSecret.DB_PASSWORD

            echo "Secrets fetched successfully"
        }
    }
}
```

### Required IAM Permission

Your AWS IAM user must have this permission to read the secret:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:ap-south-1:*:secret:petclinic/db*"
        }
    ]
}
```

### Common Errors

| Error Message | Meaning | Fix |
|---|---|---|
| `Unable to locate credentials` | Jenkins has no AWS creds | Re-run setup script |
| `AccessDeniedException` | IAM user lacks permission | Add `GetSecretValue` permission |
| `ResourceNotFoundException` | Wrong secret name | Double check `petclinic/db` in AWS |
| `readJSON` fails | Secret is not valid JSON | Check format in AWS console |

---

## 7. Stage 2 — Checkout Code

### What This Does

Clones your Spring PetClinic source code from GitHub into the Jenkins workspace.

```
GitHub Repository                    Jenkins Workspace
┌────────────────────┐               ┌────────────────────────────┐
│ spring-petclinic   │               │ /var/lib/jenkins/workspace/ │
│ ├── Jenkinsfile    │  git clone    │ spring-petclinic/           │
│ ├── pom.xml        │ ───────────▶  │ ├── Jenkinsfile             │
│ ├── src/           │               │ ├── pom.xml                 │
│ └── target/        │               │ ├── src/                    │
└────────────────────┘               └────────────────────────────┘
```

### The Code

```groovy
stage('Checkout Code') {
    steps {
        git branch: 'main',
        //   ↑ which branch to clone
        //     change to 'master' if your repo uses master

            url: 'https://github.com/spring-projects/spring-petclinic.git'
        //   ↑ the GitHub URL of your project
        //     change this to your own repo URL

        echo "Code checked out successfully"
    }
}
```

> **Tip:** If you are using a private repository, add credentials:
> ```groovy
> git branch: 'main',
>     credentialsId: 'github-credentials',
>     url: 'https://github.com/yourname/your-repo.git'
> ```

---

## 8. Stage 3 — Build and Test (JUnit)

### What is Maven?

Maven is a **build tool** for Java. It:
- Downloads all libraries your project needs (from the internet, once)
- Compiles your `.java` files into `.class` files
- Packages everything into one `.jar` file
- Runs your tests automatically

### What is a JAR File?

JAR = Java ARchive. It is like a ZIP file that contains:
```
spring-petclinic-3.3.0.jar
├── com/example/petclinic/   ← your compiled code
├── lib/                      ← all dependencies packed in
├── resources/                ← config files, templates
└── META-INF/MANIFEST.MF      ← tells Java which class to run
```

You can run it directly: `java -jar spring-petclinic-3.3.0.jar`

### What is JUnit?

JUnit is a **testing framework** for Java. It lets developers write test code that verifies their real code works correctly.

```java
// Example JUnit test
@Test
public void testAddition() {
    int result = calculator.add(2, 3);
    assertEquals(5, result);  // if result is NOT 5, test FAILS
}
```

Jenkins collects all test results and shows them as graphs on the dashboard.

### Build Lifecycle — What `mvn clean package` Does Step by Step

```
mvn clean package
│
├── clean       → Delete old compiled files from target/ folder
│                 Fresh start every time
│
├── validate    → Check pom.xml is valid
│
├── compile     → Convert .java files → .class files
│                 src/main/java/ → target/classes/
│
├── test        → Run all JUnit tests automatically
│                 src/test/java/ → results in target/surefire-reports/
│                 ⚠️  If any test FAILS → build STOPS here
│
├── package     → Bundle everything into a JAR file
│                 target/spring-petclinic-3.3.0.jar
│
└── Done ✅
```

### The Code — Line by Line

```groovy
stage('Build & Test') {
    steps {
        sh """
            mvn clean package \
            ↑   ↑     ↑
            ↑   ↑     package = compile + test + create JAR
            ↑   clean = delete old files first
            mvn = run Maven

                -Dspring.datasource.url=${env.DB_URL} \
                ↑ Pass the DB URL we fetched from AWS Secrets Manager
                ↑ Spring Boot reads this to connect to database

                -Dspring.datasource.username=${env.DB_USERNAME} \
                ↑ DB username from AWS secret

                -Dspring.datasource.password=${env.DB_PASSWORD} \
                ↑ DB password from AWS secret

                --batch-mode
                ↑ Run in non-interactive mode
                ↑ Required for CI/CD — Maven won't ask questions
        """
    }

    post {
    //  ↑
    //  post inside a stage runs AFTER that specific stage
    //  'always' means: run this whether stage passed or failed

        always {
            junit '**/target/surefire-reports/*.xml'
            //     ↑
            //     ** means "search in any folder"
            //     surefire-reports/ is where Maven saves JUnit results
            //     *.xml means "all XML files"
            //
            //     Jenkins reads these XML files and:
            //     → Shows pass/fail count on dashboard
            //     → Draws test trend graphs over time
            //     → Shows which specific tests failed and why
        }
    }
}
```

### What JUnit Results Look Like in Jenkins

After the pipeline runs, go to your Jenkins job and you will see:

```
Test Result:
  Total: 142 tests
  Passed: 140 ✅
  Failed: 2   ❌
  Skipped: 0

Failed Tests:
  ├── PetControllerTest.testCreateOwner → AssertionError: expected 200 but was 404
  └── VisitControllerTest.testAddVisit  → NullPointerException at line 45
```

---

## 9. Stage 4 — SonarQube Analysis

### What is SonarQube?

SonarQube is a **code quality analyser**. Think of it as having 3 reviewers read your code:

```
Your Code
    │
    ├──▶ Bug Detector        → finds code that WILL break at runtime
    │
    ├──▶ Security Scanner    → finds vulnerabilities hackers can exploit
    │
    ├──▶ Quality Checker     → finds poorly written code (code smells)
    │
    └──▶ Coverage Reporter   → checks how much code your tests cover
```

### What SonarQube Finds — Real Java Examples

**Bug Example:**
```java
// ❌ BAD — will crash with NullPointerException
String name = user.getName();
if (name.equals("admin")) { ... }

// ✅ GOOD — SonarQube wants this
if ("admin".equals(user.getName())) { ... }
```

**Vulnerability Example:**
```java
// ❌ BAD — SQL Injection vulnerability
String query = "SELECT * FROM users WHERE id = " + userId;

// ✅ GOOD — use prepared statements
PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
ps.setString(1, userId);
```

**Code Smell Example:**
```java
// ❌ BAD — method is 300 lines long, too complex
public void processEverything() {
    // hundreds of lines...
}

// ✅ GOOD — break into small focused methods
public void processPayment() { ... }
public void sendNotification() { ... }
public void updateInventory() { ... }
```

### Must Do Before the Pipeline — SonarQube Setup

**Step 1 — Generate a token in SonarQube:**
```
URL: http://<your-ip>:32000
Login: admin / admin

Navigate to:
  Top right → My Account → Security → Generate Tokens

  Name: jenkins-token
  Type: Global Analysis Token
  Click: Generate

  COPY THE TOKEN (shown only once):
  Example: sqa_7f3b9c2e1a4d5f8e9b2c3d4e5f6a7b8c
```

**Step 2 — Add token to Jenkins:**
```
Jenkins → Manage Jenkins → Credentials
  → (global) → Add Credentials

  Kind:   Secret text
  Secret: sqa_7f3b9c2e1a4d5f8e9b2c3d4e5f6a7b8c
  ID:     sonar-token
  Save
```

**Step 3 — Configure SonarQube server in Jenkins:**
```
Jenkins → Manage Jenkins → Configure System
  → SonarQube servers → Add SonarQube

  Name:                 SonarQube
                        ↑ This EXACT name goes in Jenkinsfile
  Server URL:           http://<your-ip>:32000
  Server auth token:    sonar-token (pick from dropdown)
  Save
```

**Step 4 — Configure SonarQube webhook (so Jenkins gets results back):**
```
SonarQube → Administration → Configuration → Webhooks → Create

  Name: Jenkins
  URL:  http://<your-ip>:8095/sonarqube-webhook/
        ↑ This is the Jenkins URL
        ↑ SonarQube will POST results here when analysis finishes
  Save
```

### Why SonarQube Must Run AFTER Build

```
Build stage produces these files:
├── target/classes/           ← SonarQube reads compiled .class files
│                               (NOT raw .java source files)
│
└── target/surefire-reports/  ← SonarQube reads JUnit XML results
                                to calculate code coverage %

If you run SonarQube BEFORE build:
→ target/ folder doesn't exist yet
→ SonarQube has nothing to read
→ Analysis FAILS
```

### The Code — Line by Line

```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
        //  ↑                ↑
        //  Jenkins plugin   Must EXACTLY match the name in
        //  function         Jenkins → Configure System → SonarQube servers
        //
        //  What withSonarQubeEnv does AUTOMATICALLY:
        //  1. Reads SonarQube URL from Jenkins config
        //  2. Reads the auth token from Jenkins credentials
        //  3. Injects both as environment variables
        //     so Maven knows where to send the report
        //  You don't need to pass URL or token manually!

            sh """
                mvn sonar:sonar \
                //  ↑
                //  'sonar:sonar' is a Maven GOAL
                //  A goal is a specific task Maven can perform
                //  This goal runs the SonarQube scanner

                    -Dsonar.projectKey=spring-petclinic \
                    //  Unique identifier for this project in SonarQube
                    //  If it doesn't exist, SonarQube creates it automatically
                    //  Used to find this project's dashboard in SonarQube UI

                    -Dsonar.projectName='Spring PetClinic' \
                    //  Display name shown in SonarQube dashboard
                    //  Can have spaces (use quotes if it does)

                    -Dsonar.java.binaries=target/classes \
                    //  WHERE are the compiled Java .class files?
                    //  Maven puts them here after 'compile' phase
                    //  SonarQube reads bytecode, not source code

                    --batch-mode
                    //  Run non-interactively (required for CI/CD)
            """
        }
    }
}
```

### What SonarQube Dashboard Shows

After the scan, go to `http://<your-ip>:32000`:

```
Project: Spring PetClinic
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality Gate:  ● PASSED

Bugs:            0        Reliability:  A ✅
Vulnerabilities: 0        Security:     A ✅
Code Smells:     12       Maintainability: A ✅
Coverage:        78.5%    (of 1240 lines)
Duplications:    2.1%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 10. Stage 5 — Quality Gate

### What is a Quality Gate?

A Quality Gate is a **set of rules** that your code must pass before the pipeline continues.

Think of it like a **security checkpoint at an airport**:
- You must pass EVERY check (no bugs, good coverage, no vulnerabilities)
- If you fail ANY check → you don't proceed
- It doesn't matter how good everything else is

### Default Quality Gate Rules in SonarQube

```
Rule                             Required Value    Meaning
───────────────────────────────────────────────────────────────
New Code Coverage                >= 80%            80% of new code must be tested
New Duplicated Lines             < 3%              Less than 3% copy-pasted code
New Maintainability Rating       = A               Code smells must be minimal
New Reliability Rating           = A               No new bugs allowed
New Security Rating              = A               No new vulnerabilities allowed
```

You can view/edit rules at: `SonarQube → Quality Gates → Sonar way`

### Quality Gate vs Analysis — What is the Difference?

```
Stage: SonarQube Analysis
    → Jenkins sends code TO SonarQube
    → SonarQube starts analysing (takes 1-3 minutes)
    → Jenkins does NOT wait — it immediately moves on
    → This stage just sends the job, doesn't wait for result

Stage: Quality Gate (separate stage)
    → Jenkins STOPS and waits
    → Polls SonarQube every few seconds: "Are you done?"
    → SonarQube finishes and responds: PASS or FAIL
    → If PASS → pipeline continues to JFrog upload
    → If FAIL → pipeline aborts immediately, no artifact uploaded
```

### The Code — Line by Line

```groovy
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
        //  ↑
        //  Safety net — if SonarQube takes longer than 5 minutes
        //  to respond (slow network, server busy, etc.)
        //  Jenkins will STOP WAITING and mark this stage as failed
        //  Without this, Jenkins could hang forever

            waitForQualityGate abortPipeline: true
            //  ↑                ↑
            //  Jenkins plugin   abortPipeline: true means:
            //  function         If quality gate FAILS →
            //  that polls       stop the ENTIRE pipeline
            //  SonarQube        Don't upload to JFrog
            //                   Don't proceed with anything
            //
            //  If you set abortPipeline: false
            //  the pipeline continues even if quality gate fails
            //  (not recommended — defeats the purpose)
        }
    }
}
```

### Quality Gate Flow

```
                    Jenkins
                       │
              waitForQualityGate
                       │
         ┌─────────────▼────────────┐
         │   Polling SonarQube...   │
         │   (every 5 seconds)      │
         └─────────────┬────────────┘
                       │
              SonarQube responds
                       │
           ┌───────────┴───────────┐
           │                       │
         PASS ✅                 FAIL ❌
           │                       │
    Continue pipeline          Abort pipeline
           │                  No JFrog upload
           ▼                  Build marked FAILED
    Upload to JFrog
```

---

## 11. Stage 6 — Upload to JFrog Artifactory

### What is JFrog Artifactory?

JFrog is a **universal artifact repository**. Think of it as a **warehouse** for software:

```
JFrog Artifactory Warehouse
├── libs-release-local        ← finished, stable builds  (YOU UPLOAD HERE)
│   └── spring-petclinic/
│       └── 3.3.0/
│           └── spring-petclinic-3.3.0.jar
│
├── libs-snapshot-local       ← work in progress builds
│   └── spring-petclinic/
│       └── 3.4.0-SNAPSHOT/
│
└── libs-remote               ← cached copies from internet (Maven Central)
```

### Why Use JFrog Instead of Just Saving the File?

```
Without JFrog:
→ JAR file saved on Jenkins server
→ Jenkins server crashes → file gone ❌
→ Tester on another machine can't access it ❌
→ No version history ❌
→ Can't tell which version was deployed ❌

With JFrog:
→ JAR file stored in dedicated artifact server ✅
→ Every version saved with metadata ✅
→ Any team member can download any version ✅
→ Full audit trail of who uploaded what when ✅
→ Can rollback to any previous version ✅
```

### JFrog Setup Before Pipeline

**Step 1 — Create the repository in JFrog:**
```
URL: http://<your-ip>:30465
Login: admin / password

Go to: Administration → Repositories → Local → Create Local Repository
  Package Type: Maven
  Repository Key: libs-release-local
  Save & Finish
```

**Step 2 — Add JFrog credentials to Jenkins:**
```
Jenkins → Manage Jenkins → Credentials → Add Credentials
  Kind:     Username with password
  Username: admin
  Password: password
  ID:       jfrog-credentials
  Save
```

### The Code — Line by Line

```groovy
stage('Upload to JFrog') {
    steps {
        script {

            // Ask Maven to tell us the version from pom.xml
            // This way we never hardcode version numbers
            def version = sh(
                script: """
                    mvn help:evaluate \
                    //  ↑ Maven goal to evaluate expressions

                        -Dexpression=project.version \
                        //  ↑ Ask for the value of project.version
                        //    Maven reads this from pom.xml
                        //    Returns: "3.3.0"

                        -q \
                        //  ↑ quiet mode — suppress extra Maven output

                        -DforceStdout
                        //  ↑ print the result to stdout
                        //    (required for returnStdout to capture it)
                """,
                returnStdout: true  // capture the printed version
            ).trim()
            // version = "3.3.0"


            def appName = 'spring-petclinic'
            def jarFile = "target/${appName}-${version}.jar"
            // jarFile = "target/spring-petclinic-3.3.0.jar"


            // Verify the JAR file actually exists
            // If the build failed silently, this catches it
            // sh "ls ..." fails if file doesn't exist → stage fails
            sh "ls -lh ${jarFile}"


            // withCredentials safely injects credentials from Jenkins store
            // NEVER hardcode passwords directly in the Jenkinsfile
            withCredentials([usernamePassword(
                credentialsId: 'jfrog-credentials',
                //              ↑ must match the ID you set in Jenkins credentials

                usernameVariable: 'JFROG_USER',
                //  ↑ Jenkins creates env var JFROG_USER with the username

                passwordVariable: 'JFROG_PASS'
                //  ↑ Jenkins creates env var JFROG_PASS with the password
            )]) {

                def jfrogUrl  = "http://<your-server-ip>:30465/artifactory"
                def repo      = "libs-release-local"
                def destPath  = "${repo}/${appName}/${version}/${appName}-${version}.jar"
                // destPath = "libs-release-local/spring-petclinic/3.3.0/spring-petclinic-3.3.0.jar"

                sh """
                    curl \
                    //  ↑ curl is a command line tool to make HTTP requests
                    //    Like a browser, but from the terminal

                        -u ${JFROG_USER}:${JFROG_PASS} \
                        //  ↑ -u = authenticate
                        //    format is username:password

                        -T ${jarFile} \
                        //  ↑ -T = Transfer this file (upload)
                        //    this is the local JAR file path

                        -X PUT \
                        //  ↑ HTTP method PUT = upload/store a file
                        //    GET  = download something
                        //    POST = send form data
                        //    PUT  = upload a file ← this one

                        "${jfrogUrl}/${destPath}"
                        //  ↑ Full destination URL in JFrog
                        //
                        //    http://<ip>:30465       → JFrog server
                        //    /artifactory/           → JFrog base path (always required)
                        //    libs-release-local/     → repository
                        //    spring-petclinic/       → app folder
                        //    3.3.0/                  → version folder
                        //    spring-petclinic-3.3.0.jar → the file
                """

                echo "✅ Successfully uploaded to: ${jfrogUrl}/${destPath}"
            }
        }
    }
}
```

### Verify the Upload Worked

**Method 1 — JFrog UI:**
```
http://<your-ip>:30465
→ Artifacts
→ libs-release-local
→ spring-petclinic
→ 3.3.0
→ You should see: spring-petclinic-3.3.0.jar with size and date
```

**Method 2 — Download via curl:**
```bash
curl -u admin:password \
     -O \
     "http://<your-ip>:30465/artifactory/libs-release-local/spring-petclinic/3.3.0/spring-petclinic-3.3.0.jar"

ls -lh spring-petclinic-3.3.0.jar
# Should show the file with correct size
```

### JFrog Common Errors

| Error | Meaning | Fix |
|---|---|---|
| `curl: (7) Failed to connect` | JFrog is not running | `kubectl get pods -n devtools` |
| `HTTP 401 Unauthorized` | Wrong credentials | Check Jenkins credentials |
| `HTTP 404 Not Found` | Repository doesn't exist | Create `libs-release-local` in JFrog UI |
| `HTTP 403 Forbidden` | User can't deploy | Check user permissions in JFrog |
| `No such file: target/*.jar` | Build failed, no JAR | Fix Build stage errors first |

---

## 12. Complete Jenkinsfile

Copy this entire file into your project root as `Jenkinsfile`:

```groovy
pipeline {
    agent any

    tools {
        maven 'Maven'    // must match name in Jenkins Global Tool Configuration
        jdk 'Java11'     // Spring PetClinic requires Java 11
    }

    environment {
        // ── App Info ────────────────────────────────────────────
        APP_NAME     = 'spring-petclinic'

        // ── AWS Settings ─────────────────────────────────────────
        AWS_REGION   = 'ap-south-1'       // change to your region
        SECRET_NAME  = 'petclinic/db'     // your secret name in AWS

        // ── SonarQube ────────────────────────────────────────────
        SONAR_PROJECT = 'spring-petclinic'
        SONAR_HOST    = 'http://<your-server-ip>:32000'

        // ── JFrog ────────────────────────────────────────────────
        JFROG_URL    = 'http://<your-server-ip>:30465/artifactory'
        JFROG_REPO   = 'libs-release-local'
    }

    stages {

        // ── STAGE 1: Fetch secrets from AWS ─────────────────────
        stage('Get Secrets from AWS') {
            steps {
                script {
                    def secret = sh(
                        script: """
                            aws secretsmanager get-secret-value \
                                --secret-id ${SECRET_NAME} \
                                --region ${AWS_REGION} \
                                --query SecretString \
                                --output text
                        """,
                        returnStdout: true
                    ).trim()

                    def jsonSecret  = readJSON text: secret
                    env.DB_URL      = jsonSecret.DB_URL
                    env.DB_USERNAME = jsonSecret.DB_USERNAME
                    env.DB_PASSWORD = jsonSecret.DB_PASSWORD

                    echo "✅ Secrets fetched from AWS"
                }
            }
        }

        // ── STAGE 2: Clone source code ───────────────────────────
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/spring-projects/spring-petclinic.git'
                echo "✅ Code checked out"
            }
        }

        // ── STAGE 3: Build app and run JUnit tests ───────────────
        stage('Build & Test') {
            steps {
                sh """
                    mvn clean package \
                        -Dspring.datasource.url=${env.DB_URL} \
                        -Dspring.datasource.username=${env.DB_USERNAME} \
                        -Dspring.datasource.password=${env.DB_PASSWORD} \
                        --batch-mode
                """
            }
            post {
                always {
                    // Publish JUnit results to Jenkins dashboard
                    junit '**/target/surefire-reports/*.xml'
                    echo "✅ JUnit results published"
                }
            }
        }

        // ── STAGE 4: Scan code quality with SonarQube ───────────
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${SONAR_PROJECT} \
                            -Dsonar.projectName='Spring PetClinic' \
                            -Dsonar.java.binaries=target/classes \
                            --batch-mode
                    """
                }
                echo "✅ SonarQube analysis submitted"
            }
        }

        // ── STAGE 5: Wait for SonarQube quality gate result ──────
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                echo "✅ Quality Gate passed"
            }
        }

        // ── STAGE 6: Upload artifact to JFrog ───────────────────
        stage('Upload to JFrog') {
            steps {
                script {
                    def version = sh(
                        script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout',
                        returnStdout: true
                    ).trim()

                    def jarFile  = "target/${APP_NAME}-${version}.jar"
                    def destPath = "${JFROG_REPO}/${APP_NAME}/${version}/${APP_NAME}-${version}.jar"

                    sh "ls -lh ${jarFile}"

                    withCredentials([usernamePassword(
                        credentialsId: 'jfrog-credentials',
                        usernameVariable: 'JFROG_USER',
                        passwordVariable: 'JFROG_PASS'
                    )]) {
                        sh """
                            curl -u ${JFROG_USER}:${JFROG_PASS} \
                                 -T ${jarFile} \
                                 -X PUT \
                                 "${JFROG_URL}/${destPath}"
                        """
                    }
                    echo "✅ Artifact uploaded to JFrog: ${JFROG_URL}/${destPath}"
                }
            }
        }

    }

    // ── POST: Runs after ALL stages finish ──────────────────────
    post {
        success {
            echo "🎉 Pipeline SUCCESS! All stages completed."
        }
        failure {
            echo "❌ Pipeline FAILED! Check logs above for errors."
        }
        always {
            cleanWs()    // delete workspace to free disk space
        }
    }
}
```

---

## 13. What is `-D` in Maven Commands?

`-D` stands for **"Define a property"**. It is how you pass a setting into Maven from the outside, without editing any file.

### Format

```
-D<property.name>=<value>
     ↑                ↑
  property name     value you want to set
```

### Real Life Analogy

Maven is like a **chef** following a recipe book. The recipe says:

```
"Add salt — use the default amount from the pantry"
```

But YOU want a specific amount. You shout from outside:

```bash
-Dsalt.amount=2spoons
```

The chef ignores the pantry and uses YOUR value instead. That is exactly what `-D` does — it **overrides or sets a property without touching any file**.

### Examples from This Pipeline

```bash
# Maven property                    What it does
─────────────────────────────────────────────────────────────────────────
-Dspring.datasource.url=jdbc:...    Set the database URL for Spring Boot
-Dspring.datasource.password=pass   Set the database password
-Dsonar.projectKey=my-app          Set the SonarQube project identifier
-Dsonar.host.url=http://ip:32000   Tell Maven where SonarQube server is
-Dexpression=project.version       Ask Maven to evaluate project.version
-DforceStdout                       Force Maven to print result to stdout
-Dmaven.test.skip=true             Skip running tests (use when needed)
-q                                  Quiet mode — suppress most output
```

### Properties vs Hardcoding

```
❌ Hardcoded in pom.xml or application.properties:
   spring.datasource.password=MyPassword123

   Problem: password is in the file → in Git → everyone sees it

✅ Passed with -D at runtime:
   mvn package -Dspring.datasource.password=${env.DB_PASSWORD}

   Benefit: value comes from AWS Secrets Manager at runtime
            never stored anywhere in code
```

---

## 14. Jenkins Plugin Setup

Before running the pipeline, install these plugins:

```
Jenkins → Manage Jenkins → Manage Plugins → Available

Search and install each:
┌─────────────────────────────┬────────────────────────────────────────┐
│ Plugin Name                 │ Why You Need It                        │
├─────────────────────────────┼────────────────────────────────────────┤
│ Pipeline                    │ Enables declarative Jenkinsfile syntax │
├─────────────────────────────┼────────────────────────────────────────┤
│ Git                         │ Enables git checkout in pipeline       │
├─────────────────────────────┼────────────────────────────────────────┤
│ SonarQube Scanner           │ Enables withSonarQubeEnv and           │
│                             │ waitForQualityGate functions           │
├─────────────────────────────┼────────────────────────────────────────┤
│ JUnit                       │ Enables junit() to display test results│
├─────────────────────────────┼────────────────────────────────────────┤
│ Credentials Binding         │ Enables withCredentials() function     │
├─────────────────────────────┼────────────────────────────────────────┤
│ Pipeline: AWS Steps         │ Enables AWS CLI integration            │
├─────────────────────────────┼────────────────────────────────────────┤
│ Workspace Cleanup           │ Enables cleanWs() in post block        │
└─────────────────────────────┴────────────────────────────────────────┘
```

### Configure Java and Maven in Jenkins

```
Jenkins → Manage Jenkins → Global Tool Configuration

JDK:
  Name:        Java11
  JAVA_HOME:   /usr/lib/jvm/java-11-openjdk-amd64

Maven:
  Name:        Maven
  Version:     3.9.x (tick "Install automatically")
  Save
```

---

## 15. Troubleshooting Guide

### Jenkins Cannot Connect to SonarQube

```bash
# Check SonarQube pod is running
kubectl get pods -n devtools

# If pod is not running, check why
kubectl describe pod sonarqube-sonarqube-0 -n devtools

# Check SonarQube logs
kubectl logs sonarqube-sonarqube-0 -n devtools
```

### Jenkins Cannot Connect to JFrog

```bash
# Check JFrog pod is running
kubectl get pods -n devtools

# Test connection manually
curl -u admin:password http://<your-ip>:30465/artifactory/api/system/ping
# Expected response: OK
```

### AWS Credentials Not Working

```bash
# Test AWS credentials as Jenkins user
sudo -u jenkins aws sts get-caller-identity
# Should return your AWS account ID and IAM user

# Verify credentials file exists
ls -la /var/lib/jenkins/.aws/
```

### Build Fails — Cannot Find JAR

```bash
# Check what Maven actually produced
ls -lh target/*.jar

# Check Maven build output for errors
# Look for: BUILD FAILURE and the line before it
```

### Quality Gate Timeout

```
Problem:   waitForQualityGate hangs and times out
Root cause: Webhook not configured — SonarQube never notified Jenkins

Fix:
  SonarQube → Administration → Webhooks → Create
  Name: Jenkins
  URL:  http://<your-ip>:8095/sonarqube-webhook/
```

### PVC Stuck Pending in Kubernetes

```bash
# Check StorageClass exists
kubectl get storageclass

# Check PVC status
kubectl get pvc -n devtools

# Create host directories if missing
sudo mkdir -p /data/sonarqube /data/artifactory /data/artifactory-db
```

---

## 📌 Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│                    PIPELINE QUICK REFERENCE                      │
├──────────────────────┬──────────────────────────────────────────┤
│ Jenkins              │ http://<ip>:8095                         │
│ SonarQube            │ http://<ip>:32000  admin/admin           │
│ JFrog                │ http://<ip>:30465  admin/password        │
├──────────────────────┼──────────────────────────────────────────┤
│ mvn clean package    │ Build + test + create JAR                │
│ mvn sonar:sonar      │ Send code to SonarQube for analysis      │
│ -D<name>=<value>     │ Override/set a Maven property            │
│ returnStdout: true   │ Capture shell command output             │
│ withSonarQubeEnv     │ Inject SonarQube URL + token             │
│ waitForQualityGate   │ Wait for SonarQube pass/fail verdict     │
│ withCredentials      │ Safely inject username + password        │
│ curl -T file -X PUT  │ Upload file via HTTP PUT                 │
├──────────────────────┼──────────────────────────────────────────┤
│ Stage order          │ AWS → Checkout → Build → Sonar →        │
│                      │ Quality Gate → JFrog                     │
└──────────────────────┴──────────────────────────────────────────┘
```

---

*Built with ❤️ for learning. Every line explained. Every stage understood.*
