# Spring Boot Actuator

We know that monitoring a running application, gathering operational information like - its health, metrics, info, dump,
environment, and understanding traffic or the state of our database are needed to manage our application.  Traditionally
this was done using JMX beans.  But now, with Spring Boot Actuator we get these production-grade tools without actually
having to implement these features ourselves. Actuator is a sub-project of Spring Boot.  It uses HTTP endpoints or JMX
beans to enable us to interact with it.

## Add Actuator Dependency

```
dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```

After adding the dependency, run the application and check the endpoint: ```http://localhost:8080/actuator``` or run
```curl localhost:8080/actuator```, you will see the following response.

```json
{
   "_links": {
      "self": {
         "href": "http://localhost:8080/actuator",
         "templated": false
      },
      "health-path": {
         "href": "http://localhost:8080/actuator/health/{*path}",
         "templated": true
      },
      "health": {
         "href": "http://localhost:8080/actuator/health",
         "templated": false
      }
   }
}
```
Spring Boot returns end-points in HATEOS (Hypermedia as the engine of application state) style i.e. adds a discovery endpoint that returns links to all available
actuator endpoints. This helps to discover other actuator endpoints and their corresponding URLs.


Now, you can check the health of the actuator, using ```http://localhost:8080/actuator/health``` or run
```curl localhost:8080/actuator/health```, you will see the following response:

```json
{
   "status": "UP"
}
```

## Add a corresponding Actuator test

Create ```com.tsys.springflyway.SpringFlywayActuatorTest``` and add a corresponding test within that ensures that the
Actuator is working:

```java
@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Tags({
        @Tag("In-Process"),
        @Tag("ComponentTest")
})
@TestPropertySource("/test.properties")
public class SpringFlywayActuatorTest {

   @Autowired
   private TestRestTemplate client;

   @Test
   public void actuatorManagementEndpointWorks() {
      // Given-When
      final ResponseEntity<Map> response = client.getForEntity("/actuator", Map.class);

      // Then
      assertThat(response.getStatusCode(), is(HttpStatus.OK));
      assertTrue(response.getBody().containsKey("_links"));
   }
}
```

## Enable Other End-points or Exclusively select or Disable End-points
1. Now, the Actuator comes with most endpoints disabled.  In order to enable all the endpoints,
   in the ```application-development.properties``` file, add

   ```properties
   management.endpoints.web.exposure.include = *
   ```

2. To expose all enabled endpoints except one (e.g., /loggers), we use:

   ```properties
   management.endpoints.web.exposure.include = *
   management.endpoints.web.exposure.exclude = loggers
   ```

3. If you want selected features, provide a list:

   ```properties
   management.endpoints.web.exposure.include = health,env,info,beans,metrics,loggers
   ```

   Some of the URLs you see, for example in metrics section:
   ```json
       "metrics-requiredMetricName": {
           "href": "http://localhost:8080/actuator/metrics/{requiredMetricName}",
           "templated": true
       },
       "metrics": {
           "href": "http://localhost:8080/actuator/metrics",
           "templated": false
       }
   ```

   Go to Metrics and select a particular one and get the details on that metric.  For example, to get
   metric - JVM info, point the browser to:

   ```
   http://localhost:8080/actuator/metrics/jvm.info
   ```

   and You should see:

   ```json
   {
     "name": "jvm.info",
     "description": "JVM version info",
     "measurements": [
       {
         "statistic": "VALUE",
         "value": 1.0
       }
     ],
     "availableTags": [
       {
         "tag": "vendor",
         "values": [
           "Oracle Corporation"
         ]
       },
       {
         "tag": "runtime",
         "values": [
           "Java(TM) SE Runtime Environment"
         ]
       },
       {
         "tag": "version",
         "values": [
           "17.0.10+11-LTS-240"
         ]
       }
     ]
   }
   ```

4. Make sure for each of the Actuator features add a corresponding test in the
   ```com.tsys.springflyway.SpringFlywayActuatorTest``` class.  We have used the following Actuator features:

   1. env
   2. info
   3. beans
   4. metrics
   5. loggers
   6. health

   So we need 6 tests:

   ```java
     @Test
     public void actuatorHealthEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/health", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
   
     @Test
     public void actuatorEnvironmentEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/env", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
   
     @Test
     public void actuatorInfoEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/info", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
     @Test
     public void actuatorBeansEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/beans", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
   
     @Test
     public void actuatorMetricsEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/metrics", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
   
     @Test
     public void actuatorLoggersEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/loggers", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
   
   ```

## Enabling/Disabling Specific Endpoints
We can get a more fine-grained control for enabling or disabling the above configured endpoints.
1. Let us disable the health endpoint by adding:

   ```properties
   management.endpoint.health.enabled = false
   ```

   There is no need to touch the below property to exclude the
   web exposure.

   ```properties
   management.endpoints.web.exposure.include = health
   ```

   After restarting the application you should not see the health end-point in the HATEOS actuator GET call.  
   You may verify this by running the test and the corresponding health test should fail

2. Similar to above you may try the ```/info``` endpoint by adding:

   ```properties
   management.endpoint.info.enabled = false
   ```

   With the ```/info``` endpoint, you can additionally control the sub-information like
   build, git, java like this:

   ```properties
   # Does not show 'app' node
   management.info.env.enabled = false
   
   # Does not show 'java' node
   management.info.java.enabled = false  
   ```

3. Let's now add a ```/shutdown``` end-point and enable it.  For this add:

   ```properties
   management.endpoint.shutdown.enabled = true
   management.endpoints.web.exposure.include = shutdown
   ```

   As shutdown was not added earlier, we need to add the ```management.endpoints.web.exposure.include``` to add the
   shutdown feature.  Restart the application and you should see the HATEOS response containing the shutdown link:

   ```json
   "shutdown": {
     "href": "http://localhost:8080/actuator/shutdown",
     "templated": false
   }
   ```
   If you click use this as a GET request it won't work because this end-point accepts only POST request.  So, use
   Postman or use:

   ```shell
   curl -X POST http://localhost:8080/actuator/shutdown
   ```

   This will shut the application down!  In reality, this is not kept open in production like this.

## Change Management Port
Actuator defaults to running on the same port as the application. By adding in ```application-development.properties```
file, you can override that setting:

```properties
management.server.port: 10001
management.server.address: 127.0.0.1
```

## The ```/env``` Endpoint
If you point the browser to the ```/env``` endpoint on http://localhost:8080/actuator/env, you will see all the
enviromental details like:
* System Properties like - ```java.class.path```, ```file.separator```, ```user.dir```, ```PID``` etc...
* System Environment Variables like ```HOME```, ```PATH```, ```USER```, ```SHELL```, ```JAVA_HOME``` etc...
* All application properties
* Servlet Context Init Params
* Active Profiles
* If you have Spring devtools install, then all devtools properties

But, by default all the values are hidden.  In order to see these values, add the following property
in ```application.properties``` file, restart the app and point the browser to ```/env``` endpoint again.

```properties
# Allowed values are never, when-authorized, always
management.endpoint.env.show-values = ALWAYS
```

## The ```/loggers``` Endpoint
Access the ```/loggers``` endpoint at ```http://localhost:8080/actuator/loggers```.
You will see that it displays a list of all the configured loggers in the application
with their corresponding log levels. The details of an individual logger by passing the
logger name in the URL like this - ```http://localhost:8080/actuator/loggers/{name}```

For example, to get the details of the root logger, use the URL
http://localhost:8080/actuator/loggers/ROOT.

### Changing Log levels at runtime
Now, so far we are only able to view, the log-levels, But what if, the application is
facing some issue in production and we need to enable DEBUG logging for some time to
get more details about the issue.  Here is what we do -

For example, let's change the log level of the root logger to DEBUG at runtime,
make a POST request to the URL http://localhost:8080/actuator/loggers/ROOT with the payload:

```shell
curl -X 'POST' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
 'http://localhost:8080/actuator/loggers/ROOT' \
 -d '{ 
    "configuredLevel" : "DEBUG" 
  }' 
```

To check whether DEBUG is enabled or not, go to: http://localhost:8080/actuator/loggers/ROOT and you should see:

```json
{
  "configuredLevel": "DEBUG",
  "effectiveLevel": "DEBUG"
}
```

Likewise, you can change other loggers that are only specific to your package(s) by simply changing the name in
the above URL.

## The ```/flyway``` Endpoint
If you have Flyway in your application, then all you need to do do is simply add the following
to ```application.properties```:

```properties
management.endpoint.flyway.enabled = true
management.endpoints.web.exposure.include = ..., ..., flyway
```
Make sure that Flyway is also enabled in the ```application.properties```:
```properties
spring.flyway.enabled = true
```

Once you start the application and hit the http://localhost:8080/actuator/flyway, you will see
all the migrations.

**NOTE:** In case you get an error while starting the application that says -
```No Enum Constant found for UNDO_SQL```, then go to the backend ```schema_version``` table and
issue the following query:

```mysql-sql
DELETE FROM schema_version WHERE type = 'UNDO_SQL';
```
and then restart the application and hit the flyway actuator end-point.

## Configuring Endpoints
```management.endpoint.<name>``` prefix uniquely identifies the endpoint
that is being configured.

Each endpoint can be customized with properties using the format
```management.endpoint.<name>.<property to customize>```.

For Example:
```properties
management.endpoint.env.enabled = true
management.endpoint.env.show-values = WHEN_AUTHORIZED
management.endpoint.env.roles = admin
```

And finally to expose it over web, use the prefix
```management.endpoints.web.exposure.include = <name1>, <name2>, ...```

## Customizing the ```/info``` Endpoint
If you go to the ```http://localhost:8080/actuator/info```, you will find that it is empty.  This is where we can
customize this endpoint.  Let's include build and git details information of the project here:

NOTE: Below excerpt from: [https://reflectoring.io/spring-boot-info-endpoint/](https://reflectoring.io/spring-boot-info-endpoint/)

Spring collects useful application information from various ```InfoContributor``` beans defined in the application
context. Below is a summary of the default ```InfoContributor``` beans:

| ID	   | Bean Name	                 | Usage                                                               |
|-------|----------------------------|------------------------------------------------------------------------|
| build | BuildInfoContributor	      | Exposes build information.                                             |
| env	 | EnvironmentInfoContributor | Exposes any property from the Environment whose name starts with info. |
| git	 | GitInfoContributor	      | Exposes Git related information.                                       |
| java	 | JavaInfoContributor	      | Exposes Java runtime information.                                      |
| os	 | OsInfoContributor	      | Exposes OS information.                                                |

By default, the ```env``` and ```java``` contributors are disabled.

1. Let us enable the java contributor by adding the following key-value pair
   in ```application-development.properties```:

   ```properties
   management.info.java.enabled = true
   ```

   And you should see:
   ```json
   "java": {
     "version": "17.0.10",
     "vendor": {
       "name": "Oracle Corporation"
     },
     "runtime": {
       "name": "Java(TM) SE Runtime Environment",
       "version": "17.0.10+11-LTS-240"
     },
     "jvm": {
       "name": "Java HotSpot(TM) 64-Bit Server VM",
       "vendor": "Oracle Corporation",
       "version": "17.0.10+11-LTS-240"
     }
   }
   ```

2. To display app info, we say ```management.info.env.enabled = true```.
   Also, Spring can pick up any app variable with a property name starting with info. To see this in action,
   let’s add the following properties in the ```application-development.properties``` file:

   ```properties
   # shows app info
   management.info.env.enabled = true
   # shows app info 
   info.app.website = https://tsys.co.in
   info.app.author = Dhaval Dalal
   info.app.microservice.name = Spring Flyway Demo
   info.app.microservice.name = Spring Flyway Demo
   info.app.microservice.version = v1.0
   ```
   Hit the info url: ```http://localhost:8080/actuator/info``` and
   you should see something similar:

   ```json
   "app": {
     "author": "Dhaval Dalal",
       "microservice": {
         "name": "Spring Flyway Demo",
         "version": "1.0"
       },
       "website": "https://tsys.co.in"
   },
   ```

3. Let us now add build info to this. Adding useful build information helps to identify the build artifact
   name, version, time created, etc... esp. useful for blue-green deployments.  Spring Boot allows to add this
   information using Maven or Gradle build plugins.  For this, we add the following build info block using the
   plugin DSL to ```build.gradle```:

   ```groovy
   springBoot {
       buildInfo {
           properties {
               // Custom properties
               additional = [
                       'jar': "$project.name-$project.version" + '.jar'
               ]
           }
       }
   }
   ```
   Running the ```./gradlew clean build``` task will generate ```build/resources/main/META-INF/build-info.properties```
   file with build info (derived from the project). Using the DSL we can customize existing values or add new
   properties as shown above.

   ```json
   "build": {
     "version": "0.0.1",
     "artifact": "spring-flyway-solution",
     "name": "spring-flyway-solution",
     "jar": "spring-flyway-solution-0.0.1.jar",
     "time": "2024-04-08T05:09:07.146Z",
     "group": "com.tsys"
   }
   ```

4. Let us now add Git info to this.  This is very useful to check if the relevant code present in production or the
   distributed deployments in different pods are in sync with expectations. Spring Boot can easily include Git
   properties in the Actuator endpoint using the Maven and Gradle plugins.  Using this plugin we can generate a
   ```git.properties``` file. The presence of this file automatically configures the ```GitProperties``` bean that
   is used by the ```GitInfoContributor``` bean to collate relevant information. By default, the following information
   will be exposed:

   ```properties
   git.branch
   git.commit.id
   git.commit.time
   ```

   In the ```build.gradle``` we  add the gradle-git-properties plugin:

   ```groovy
   plugins {
     id 'com.gorylenko.gradle-git-properties' version '2.4.1'
   }
   ```

   Let’s build the project ```./gradlew clean build```. We can see ```build/resources/main/git.properties``` file is
   created. And, the actuator info endpoint will display the same data:

   ```json
   "git": {
     "branch": "main",
     "commit": {
       "id": "1ccb22e",
       "time": "2024-04-05T14:33:35Z"
     }
   }
   ```

   The following management application properties control the Git related information:
   Let's add them to ```application-development.properties```

   | Application Property	                     | Purpose                                                      |
      |---------------------------------------------|--------------------------------------------------------------|
   | ```management.info.git.enabled = false```   | Disables the Git information entirely from the info endpoint |
   | ```management.info.git.mode = full```	     | Displays all the properties from the git.properties file     |

   Now, point the browser to the ```/info``` endpoint and it will show you full Git information:

   ```json
   "git": {
       "branch": "main",
       "commit": {
         "time": "2024-04-05T14:33:35Z",
         "message": { ... },
         "id": { ... },
         "user": { ... }
       },
       "build": {
         "version": "0.0.1",
         "user": {...},
       },
       "dirty": "true",
       "tags": "",
       "total": { ... },
       "closest": { ... },
       "remote": {...}
   }
   ```

   This plugin too provides multiple ways to configure the output using the attribute ```gitProperties```. For example,
   let’s limit the keys to be present by adding below to ```build.gradle```:

   ```groovy
   gitProperties {
       keys = [
               'git.branch',
               'git.commit.id.full',
               'git.commit.time',
               'git.commit.message.short',
               'git.commit.user.name',
               'git.total.commit.count',
       ]
   }
   ```
   We add the following tests for the above parts added to the ```/info``` endpoint:

   ```java
   @ExtendWith(SpringExtension.class)
   @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
   @Tags({
           @Tag("In-Process"),
           @Tag("ComponentTest")
   })
   @TestPropertySource("/test.properties")
   public class SpringFlywayActuatorTest {
   
     ...
     ...
     ...
      
     @Test
     public void actuatorInfoEndpointHasAppInfo() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/info", Map.class);
   
       // Then
       assertTrue(response.getBody().containsKey("app"));
     }
   
     @Test
     public void actuatorInfoEndpointHasBuildInfo() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/info", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
       assertTrue(response.getBody().containsKey("build"));
     }
   
   
     @Test
     public void actuatorInfoEndpointHasGitInfo() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/info", Map.class);
   
       // Then
       assertTrue(response.getBody().containsKey("git"));
     }
   
   }
   ```
5. Add an 'OS' contribution to this ```/info``` endpoint and write a corresponding test for it.

### Problem Statement
Write a ```DockerInfoContributor``` that shows the version of the engine on which Docker is running and the
port, volume mapped information

## Customizing the ```/metrics``` Endpoint
We know that ```/metrics``` endpoint publishes information about OS and JVM as well as application-level metrics.

Spring Boot 2.0 uses Micrometer library for collecting metrics from JVM-based applications like Spring-based
application. Micrometer is now a part of the Actuator’s dependencies, so we should be good to go as long as the Actuator dependency
is in the classpath.

![SpringBoot-Actuator+Micrometer.png](images%2FSpringBoot-Actuator%2BMicrometer.png)

It converts these metrics in a format acceptable by the monitoring tools.  Micrometer is a facade between
application metrics and the metrics infrastructure developed by different monitoring/observability systems like Prometheus,
New Relic, Amazon Cloud Watch, Elastic etc... Think it to be like SLF4J, but for observability.


### Micrometer Concepts

Let us look at the abstractions Micrometer provides:
* ```Meter``` - is the interface for collecting a set of measurements or metrics about the application.
* ```MeterRegistry``` Meters in Micrometer are created from and held in a MeterRegistry.
  Each supported monitoring system has an implementation of ```MeterRegistry```.
* ```SimpleMeterRegistry``` - it holds the latest value of each meter in memory and does not export the data anywhere.
  It is autowired in a Spring Boot application.
* ```@Timed``` - An annotation that frameworks can use to add timing support to either specific types
  of end-point methods that serve web request or to all methods.


In order to gather custom metrics, we have support for:
* ```Counter``` - a counter is a cumulative metric that represents a single value that can only be
  incremented/decremented or be reset to zero on restart, e.g. how many times feature A has been used.
  They are most often queried using the ```rate()``` function to view how often an event occurs over
  a given time period.

* ```Gauge``` - a gauge is a metric that represents a single numerical snapshot of data that can arbitrarily
  go up and down, e.g. how many users are logged-in currently or CPU utilization.

* ```Timer``` - to measure time. There are also histograms and summaries e.g. how much time does request to an
  endpoint take on average.  Histograms show the distribution of observations and putting those observations
  into pre-defined buckets. They are highly performant, and values can be accurately aggregated across both
  windows of time and across numerous time series. Note that both quantile and percentile calculations are
  done on the server side at query time.  Summaries measure latencies and are best used where an accurate
  latency value is desired without configuration of histogram buckets. They are limited as they cannot
  accurately perform aggregations or averages across quantiles and can be costly in terms of required resources.
  Calculations are done on the application or service client side at metric collection time.


We now implement custom metrics into the ```/metrics``` end-point.

### Implementing Counter
Let's say we want to count how many times ```/ping``` was called.  For that matter
of fact you can choose any endpoint available in the application like the
login to log failed and successful attempts, count the number of downloads etc...

For us the ```HomeController``` serves the ```/ping``` end-point and to this we need to add the ```Counter```
such that we increment it each time this endpoint is called.

```java
@RestController
@RequestMapping("/")
public class HomeController {

   public String index() {
      return "index.html";
   }

   @GetMapping(value = "ping", produces = "application/json")
   public ResponseEntity<String> pong() {
      return ResponseEntity.ok(String.format("{ \"PONG\" : \"%s is running fine!\" }", getClass().getSimpleName()));
   }
}

```

But before we add the Counter to this code, we need to make sure that the Counter is created. For this let us create
```MetricsConfig```

```java
package com.tsys.springflyway.config;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MetricsConfig {

  @Bean
  public Counter makePingCounter(MeterRegistry meterRegistry) {
    return Counter.builder("api.ping.get")
        .description("a number of requests to /ping endpoint")
        .register(meterRegistry);
  }
}
```

Now, we need to modify the Controller class to inject this Counter and then
modify the ```pong()``` method to increment the counter value.

```java
@RestController
@RequestMapping("/")
public class HomeController {

  private Counter pingCounter;

  @Autowired
  public HomeController(Counter pingCounter) {
    this.pingCounter = pingCounter;
  }

   ...
   ...
   
  @GetMapping(value = "ping", produces = "application/json")
  public ResponseEntity<String> pong() {
    pingCounter.increment();
    return ResponseEntity.ok(String.format("{ \"PONG\" : \"%s is running fine!\" }", getClass().getSimpleName()));
  }
}
```

and we modify the ControllerSpecs to:

```java
public class HomeControllerSpecs {

   ...
   ...
   ...

   @Test
   @Order(1)
   public void health() {
      // Given-When
      final ResponseEntity<String> response = client.getForEntity("/ping", String.class);

      // Then
      assertThat(response.getStatusCode(), is(HttpStatus.OK));
      assertThat(response.getBody(), is("{ \"PONG\" : \"HomeController is running fine!\" }"));
   }

   @Test
   @Order(2)
   public void incrementsPingCountByOneWhenAPingRequestIsMade() {
      // When
      client.getForEntity("/ping", String.class);

      // Then
      final ResponseEntity<Map> response = client.getForEntity("/actuator/metrics/api.ping.get", Map.class);
      final List<Map<String, ?>> measurements = (List<Map<String, ?>>) response.getBody().get("measurements");
      final double api_ping_get = (double) measurements.get(0).get("value");
      assertThat(api_ping_get, is(2.0d));
   }
}
```

Note that we have Ordered the tests as the ```/ping``` request is invoked twice from this test and hence we make the
results deterministic.

Now, restart the application and go to the http://localhost:8080/actuator/metrics/api.ping.get
end-point and you should see this:

```json

  "name": "api.ping.get",
  "description": "a number of requests to /ping endpoint",
  "measurements": [
    {
      "statistic": "COUNT",
      "value": 0.0
    }
  ],
  "availableTags": [
    
  ]
}
```

Now, make a ping request - http://localhost:8080/ping and
revisit http://localhost:8080/actuator/metrics/api.ping.get and you should see this:

```json

  "name": "api.ping.get",
  "description": "a number of requests to /ping endpoint",
  "measurements": [
    {
      "statistic": "COUNT",
      "value": 1.0
    }
  ],
  "availableTags": [
    
  ]
}
```

### Implementing Gauge
Let us now add a Gauge for measuring total number of users in the system

```java
@RestController
@RequestMapping("/users")
@Slf4j
public class UserController {

   private final UserRepository repository;
   private final MeterRegistry meterRegistry;
   private final AtomicInteger totalUsers;

   @Autowired
   public UserController(UserRepository repository, MeterRegistry meterRegistry) {
      this.repository = repository;
      this.meterRegistry = meterRegistry;
      this.totalUsers = new AtomicInteger(0);
      Gauge.builder("api.users.total", () -> totalUsers)
              .description("total number of users in the system")
              .register(meterRegistry);
   }

   ...
   ...

   @GetMapping()
   public ResponseEntity<List<User>> getAll() {
      final List<User> users = repository.findAll();
      totalUsers.set(users.size());
      return ResponseEntity.ok(users);
   }

   ...
   ...
}
```

and the Corresponding tests in the ControllerSpecs would be:

```java
public class UserControllerSpecs {

  ...
  ...
  
  private User krishnaSaved;

  @BeforeEach
  public void givenThatAUserIsSaved() {
    final ResponseEntity<User> response = client.postForEntity("/users", krishna, User.class);
    krishnaSaved = response.getBody();
  }

  @AfterEach
  public void deleteAUserThatWasSaved() {
    client.delete(String.format("/users/%d", krishnaSaved.getId()));
  }
   
  ...
  ...

  @Test
  public void getAllUsersCapturesTotalNumberOfUsersMetricInTheSystem() {
    // Given
    client.getForEntity("/users", List.class);
    final String metricName = "api.users.total";

    // When
    final ResponseEntity<Map> apiTotalUsersMetric = client.getForEntity(String.format("/actuator/metrics/%s", metricName), Map.class);

    // Then
    assertResponseIs200OK(apiTotalUsersMetric);

    final Map metric = apiTotalUsersMetric.getBody();
    System.out.println("metric = " + metric);
    assertThat(metric.get("name"), is(metricName));
    assertThat(metric.get("description"), is("total number of users in the system"));
    final List<Map<String, ?>> measurements = (List<Map<String, ?>>) metric.get("measurements");
    final Map<String, ?> totalUsersValue = measurements.get(0);
    assertThat(totalUsersValue.get("value"), is(1.0d));
  }

  private static void assertResponseIs200OK(ResponseEntity<Map> response) {
    assertThat(response.getStatusCode(), is(HttpStatus.OK));
    assertThat(response.getHeaders().getContentType(), is(new MediaType("application", "json")));
  }
}
```

Now, make a request to - http://localhost:8080/users and visit http://localhost:8080/actuator/metrics/api.users.total
and you should see something similar to this:

```json
{
  "name": "api.users.total",
  "description": "total number of users in the system",
  "measurements": [
    {
      "statistic": "VALUE",
      "value": 3.0
    }
  ],
  "availableTags": [
    
  ]
}
```


### Implementing Timers
Let us now measure the time taken by the API to Get All the users from the database.

```java
@RestController
@RequestMapping("/users")
@Slf4j
public class UserController {
  
   ...
   ...

   @GetMapping()
   public ResponseEntity<List<User>> getAll() {
      Timer.Sample timer = Timer.start(meterRegistry);
      final List<User> users = repository.findAll();
      timer.stop(Timer.builder(api.users.get_all.time")
              .description("Time taken to get all the users from repository")
              .publishPercentileHistogram(true)
              .percentilePrecision(2)
              .publishPercentiles(0.95, 0.75, 0.50, 0.25)
              .register(meterRegistry));

      totalUsers.set(users.size());
      return ResponseEntity.ok(users);
   }
   
   ...
   ...
}
```

#### Percentiles and Averages

1. **25th Percentile** - Also known as the first, or lower, quartile. The 25th percentile
   is the value at which 25% of the answers lie below that value, and 75% of the answers lie
   above that value.

2. **50th percentile (median)** - The 50th percentile or median is the value in the very middle of a set of
   measurements.  The median cuts the data set in half.  Half of the answers lie below the median and half lie
   above the median.  In other words, 50% of measurements are under the median and 50% are over the median.
   _The median is typically a stable measurement, so it's good for seeing long-term trends. However, the median
   will typically not show short-term trends or anomalies._  Use the median as the "best case" when it comes to
   performance data, since it only represents what half of your users will experience.

3. **75th percentile** - Also known as the third, or upper, quartile.  The 75th percentile is the value where
   75% of all measurements are under it, and 25% of measurements are over it.  It is the percentile that Google
   recommends using when monitoring web vitals like - time to first byte, render time of the largest image or text
   block visible in the viewport, relative to when the user first navigated to the page, etc...  The 75th percentile
   is a good balance of representing the vast majority of measurements, and not being impacted by outliers.
   _While not as stable as the median, the 75th percentile is a good choice for seeing medium- to long-term trends._

4. **95th percentile** - The 95th percentile is the value where 95% of all measurements are under it, and 5% of
   measurements are over it. Use the 95th percentile to encompasses the experience of almost all of your users,
   with only the most severe outliers excluded. _This makes it perfect for spotting short-term trends and anomalies.
   However, the 95th percentile can be volatile, and may not be suitable for plotting long-term trends._  Historically,
   a lot of services are defined as something like "the p95 latency may not exceed 0.25 seconds."  A way of phrasing
   this same requirement so that we do get an accurate number of how close we are to violating our service level is
   "the proportion of requests in which latency exceeds 0.25 seconds must be less than 5 percent."  Instead of
   approximating the p95 and seeing if it’s below or above 0.25 seconds, we precisely define the percentage of requests
   exceeding 0.25 seconds.

5. **Average (arithmetic mean)** - The average is calculated by adding every measurement together, and then
   dividing it by the number of measurements. One important and slightly confusing thing about the average
   measurement is: it doesn't exist!

   What does that mean? Consider the following measurements: 2, 3, 5, 7. The average of these measurements
   is (2 + 3 + 5 + 7) / 4 = 4.25. But none of the measurements have a value of 4.25! This is why you might hear people
   say things like "the average person doesn't exist". Due to this, use averages sparingly.

   Averages are _best used to aggregate measurements that have a relatively even distribution_, which means that all
   the bars in the histogram are roughly the same height.

   Averages are _not suitable for aggregating measurements with highly varied distributions_, for example, most
   performance data does not have an even distribution. With such varying distributions, averages will produce
   inconsistent values across different metrics.

and the Corresponding tests in the ControllerSpecs would be:

```java
public class UserControllerSpecs {

  ...
          ...

   @Test
   public void getAllUsersCapturesTimeTakenByTheRequestToRespondMetric() {
      // Given
      client.getForEntity("/users", List.class);
      final String metricName = "api.users.get_all.time";

      // When
      final ResponseEntity<Map> executionTimeMetric = client.getForEntity(String.format("/actuator/metrics/%s", metricName), Map.class);

      // Then
      assertResponseIs200OK(executionTimeMetric);

      final Map metric = executionTimeMetric.getBody();
      assertThat(metric.get("name"), is(metricName));
      assertThat(metric.get("description"), is("Time taken to get all the users from repository"));
      assertThat(metric.get("baseUnit"), is("seconds"));
      final List<Map<String, ?>> measurements = (List<Map<String, ?>>) metric.get("measurements");
      final Map<String, ?> callCount = measurements.get(0);
      assertThat(callCount.get("value"), is(2.0d));
      final Map<String, Double> totalTime = (Map<String, Double>) measurements.get(1);
      assertTrue(totalTime.get("value") > 0d);
      final Map<String, Double> maxTime = (Map<String, Double>) measurements.get(2);
      assertTrue(maxTime.get("value") > 0d);
   }

}
```

After getting a green bar, lets start the Application and make sure you create a few users and
point the browser to http://localhost:8080/actuator/metrics/api.users.get_all.time
and you should see something similar:

```json
{
   "name": "api.users.get_all.time",
   "description": "Time taken to get all the users from repository",
   "baseUnit": "seconds",
   "measurements": [
      {
         "statistic": "COUNT",
         "value": 3.0
      },
      {
         "statistic": "TOTAL_TIME",
         "value": 0.374272286
      },
      {
         "statistic": "MAX",
         "value": 0.174272286
      }
   ],
   "availableTags": [

   ]
}
```

Now, it may not be convenient to introduce timers everywhere in the code and then to gather the stats for
performance tuning strategy.  Micrometer comes with ```@Timed``` annotation that we use to add timing support
to either specific types or to end-point methods that serve web request or to all methods.

For the ```@Timed``` annotation to work, we need to introduce in ```MetricsConfig``` a ```TimedAspect``` bean
as shown below:

```java
public class MetricsConfig {

  ...
  ...
   
  @Bean
  public TimedAspect timedAspect(MeterRegistry registry) {
    return new TimedAspect(registry);
  }
}
```

Make sure you have the below dependency in ```build.gradle``` for the above ```TimedAspect``` to compile:

```groovy
dependencies {
   implementation 'org.springframework:spring-aspects'
}
```

Now, let us add the following ```@Timed``` annotation to ```UserController``` methods:

```java
public class UserController { 
   ...
   ...

   @Timed(value = "api.users.create", description = "time taken to create a user", histogram = true, percentiles = {0.95, 0.75, 0.5, 0.25})
   @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
   public ResponseEntity create(@RequestBody User user) {
      ...
   }

   ...
   ...
   
   @Timed(value = "api.users.update", description = "time taken to update a existing user or create new one", histogram = true, percentiles = {0.95, 0.75, 0.5, 0.25})
   @PutMapping(path = {"/{id}", ""}, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
   public ResponseEntity update(@PathVariable(required = false) Optional<Long> id,
                                @RequestBody User user) {
      ...
   }
   
   ...
   ...
}
```

Also add the corresponding timer tests in ```UserControllerSpecs```

```java
public class UserControllerSpecs {
  
   ...
   ...
   
   @Test
   public void creatingAUserCapturesTimeTakenByTheRequestToCompleteMetric() {
      // Given
      final String metricName = "api.users.create";

      // When
      final ResponseEntity<Map> apiUsersCreationMetric = client.getForEntity(String.format("/actuator/metrics/%s", metricName), Map.class);

      // Then
      assertThatResponseIs200OK(apiUsersCreationMetric);

      final Map metric = apiUsersCreationMetric.getBody();
      assertThat(metric.get("name"), is(metricName));
      assertThat(metric.get("description"), is("time taken to create a user"));
      final List<Map<String, ?>> measurements = (List<Map<String, ?>>) metric.get("measurements");
      final Map<String, ?> totalUsersValue = measurements.get(0);
      assertTrue((double) totalUsersValue.get("value") >= 1.0d);
   }

   @Test
   public void updatingAUserCapturesTimeTakenByTheRequestToCompleteMetric() {
      // Given
      krishnaSaved.updateFrom(makeUser("Dhaval Dalal", "dhaval@dd.com"));
      client.put(String.format("/users/%d", krishnaSaved.getId()), krishnaSaved);
      final String metricName = "api.users.update";

      // When
      final ResponseEntity<Map> apiUsersUpdationMetric = client.getForEntity(String.format("/actuator/metrics/%s", metricName), Map.class);

      // Then
      assertThatResponseIs200OK(apiUsersUpdationMetric);

      final Map metric = apiUsersUpdationMetric.getBody();
      assertThat(metric.get("name"), is(metricName));
      assertThat(metric.get("description"), is("time taken to update a existing user or create new one"));
      final List<Map<String, ?>> measurements = (List<Map<String, ?>>) metric.get("measurements");
      System.out.println("measurements = " + measurements);
      final Map<String, ?> totalUsersValue = measurements.get(0);
      assertThat(totalUsersValue.get("value"), is(1.0d));
   }

   ...
   ...
}
```

Now create a few more users and update a few as well and see what all we get at
the http://localhost:8080/actuator/metrics endpoint.  You will see something similar:

```json
{
   "names": [
      "api.ping.get",
      "api.users.create",
      "api.users.get_all.time",
      "api.users.total",
      "api.users.update",
      ...
      ...
   ]
}
```
Instead of adding @Timed notation to individual methods, you can add it to the
whole class like this:

```java
//@Timed(value = "api.users", histogram = true, percentiles = {0.95, 0.75, 0.5, 0.25})
public class UserController {
   ...
}
```

and each method will appear in the tag.


## Using Prometheus to Monitor Application Metrics

![SpringBoot-Actuator+Micrometer+Prometheus.png](images%2FSpringBoot-Actuator%2BMicrometer%2BPrometheus.png)

### What is Prometheus?
It is an open-source systems monitoring and alerting toolkit originally built at
[SoundCloud](https://soundcloud.com/). It is basically a data-acquisition and aggregating tool.
Whereas tools like Grafana, Kibana are data visualization tools.  Prometheus visualization is not rich,
it is a bare and raw.  Hence, people use Grafana on top of it for proper data visualization and
making sense of it. It is now a standalone open source project and maintained independently of any company.

Prometheus is designed for reliability, to be the system you go to during an outage to
allow you to quickly diagnose problems. Each Prometheus server is standalone, not depending
on network storage or other remote services. You can rely on it when other parts of your
infrastructure are broken, and you do not need to setup extensive infrastructure to use it.
Prometheus works well for recording any purely numeric time series. It fits both machine-centric
monitoring as well as monitoring of highly dynamic service-oriented architectures. In a world of
microservices, its support for multi-dimensional data collection and querying is a particular strength.

### Time-Series Data and Scraping
Prometheus fundamentally stores all data as time series: streams of timestamped values belonging to the
same metric and the same set of labeled dimensions. Besides stored time series, Prometheus may generate
temporary derived time series as the result of queries.

Prometheus operates on a pull model by scraping metrics from an endpoint exposed by the application
instances at fixed intervals.  It scrapes metrics from instrumented jobs, either directly or via an intermediary
push gateway for short-lived jobs. It stores all scraped samples locally and runs rules over this
data to either aggregate and record new time series from existing data or generate alerts.
While you can use out-of-box Dashboard & Graph from Prometheus, you may use Grafana or other API
consumers to visualize the collected data.

   ```text
    Value
      ^
      |                 
      |                 
      +                       x
      |   
      |                   x
      +               x
      |        x    x 
      |        
      + x   x
      |
      |
      +-----+-----+-----+-----+-----+-----+-----> 
            1m    2m    3m    4m   
                   Time   
   ```

Not only technical metrics, but you may use Prometheus for business metrics.  But avoid using it for
100% accuracy to capture per-request stuff.  Google Analytics is another good choice for business
metrics as you don't have to write much code.

### Prometheus' Features
Prometheus' main features are:

* a multi-dimensional data model with time series data identified by metric name and key/value pairs
* ```PromQL```, a flexible query language to leverage this dimensionality
* no reliance on distributed storage; single server nodes are autonomous
* time series collection happens via a pull model over HTTP
* pushing time series is supported via an intermediary gateway
* targets are discovered via service discovery or static configuration
* multiple modes of graphing and dashboarding support

### Prometheus' Components
The Prometheus ecosystem consists of multiple components, many of which are optional:

* the main Prometheus server which scrapes and stores time series data
* client libraries for instrumenting application code
* a push gateway for supporting short-lived jobs
* special-purpose exporters for services like HAProxy, StatsD, Graphite, etc.
* an alertmanager to handle alerts
* various support tools

![prometheus-architecture.png](images%2Fprometheus-architecture.png)

### 1. Enable Prometheus Endpoint On Actuator
We need to add a Gradle Dependency ```micrometer-registry-prometheus``` in order to convert our metrics
in Micrometer-based format to Prometheus format so as to be able to monitor from Prometheus.

1. Add the following line to ```build.gradle```'s dependency section:

   ```groovy
   dependencies {
      ...
      implementation 'io.micrometer:micrometer-registry-prometheus'
      ...
   }

2. Run ```./gradlew cleanIdea idea```
3. Enable the prometheus endpoint on Actuator:
   ```properties
   management.endpoints.web.exposure.include = ..., ..., prometheus
   management.endpoint.prometheus.enabled = true
   ```
   Point the browser to http://localhost:8080/actuator/prometheus and you should see
   something similar:

   ```
   # HELP jdbc_connections_idle Number of established but idle connections.
   # TYPE jdbc_connections_idle gauge
   jdbc_connections_idle{name="dataSource",} 10.0
   # HELP jvm_gc_live_data_size_bytes Size of long-lived heap memory pool after reclamation
   # TYPE jvm_gc_live_data_size_bytes gauge
   jvm_gc_live_data_size_bytes 0.0
   # HELP jvm_threads_started_threads_total The total number of application threads started in the JVM
   # TYPE jvm_threads_started_threads_total counter
   jvm_threads_started_threads_total 32.0
   # HELP jvm_gc_pause_seconds Time spent in GC pause
   # TYPE jvm_gc_pause_seconds summary
   jvm_gc_pause_seconds_count{action="end of minor GC",cause="G1 Evacuation Pause",gc="G1 Young Generation",} 1.0
   jvm_gc_pause_seconds_sum{action="end of minor GC",cause="G1 Evacuation Pause",gc="G1 Young Generation",} 0.004
   # HELP jvm_gc_pause_seconds_max Time spent in GC pause
   # TYPE jvm_gc_pause_seconds_max gauge
   jvm_gc_pause_seconds_max{action="end of minor GC",cause="G1 Evacuation Pause",gc="G1 Young Generation",} 0.004
   ...
   ...
   ```
   Locate our Ping Counter: ```api_ping_get``` in the above.

4. Now make a few requests to endpoint where we have set-up our Gauges and Timers and then refresh to the
   Prometheus endpoint and we should see those metrics.

5. Add a corresponding ```/actuator/prometheus``` endpoint test in the ```FraudCheckerActuatorTest```:

   ```java
   public class SpringFlywayActuatorTest {
     
     ...
     ... 
      
     @Test
     public void actuatorPrometheusEndpointWorks() {
       // Given-When
       final ResponseEntity<Map> response = client.getForEntity("/actuator/prometheus", Map.class);
   
       // Then
       assertThat(response.getStatusCode(), is(HttpStatus.OK));
     }
   }
   ```


### 2. Getting, Configuring and Running Prometheus
1. Pull the latest Prometheus Image: ```docker pull prom/prometheus```
2. Create Prometheus Configuration File ```prometheus-config.yml``` in the Project root directory.  In this file
   we will add 2 jobs in Prometheus:
   1. To scrape Prometheus itself.
   2. To scrape the above metrics emitted from our application.

   ```yaml
   global:
     scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
     evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
     # scrape_timeout is set to the global default (10s).
   
   # Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
   rule_files:
   # - "first_rules.yml"
   # - "second_rules.yml"

   scrape_configs:
     # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
     - job_name: 'prometheus'
       # metrics_path defaults to '/metrics'
       # scheme defaults to 'http'.
       static_configs:
         - targets: ['127.0.0.1:9090']
   
     - job_name: 'Spring Flyway Demo - Prometheus'
       metrics_path: '/actuator/prometheus'
       scrape_interval: 5s
       static_configs:
         - targets: ['<DOCKER HOST IP OF OUR APP>:8080']
   ```
   This configuration will scrape the metrics at 5-second intervals.  
   **NOTE:** Generally have same scrape interval for entire organization.
   As we are using Docker to run Prometheus, we need to specify the IP address
   of the host machine (run ```ifconfig``` or ```ipconfig```) instead of ```localhost``` while running in Docker

3. Run the Prometheus Image:
   1. Using Docker Desktop, Start the image and in the Optional Settings:
      1. Ports section: add ```9090``` against ```9090/tcp```.
      2. Volumes section: Add
         1. Host Path: ```$PROJECT_DIR/prometheus-config.yml```
         2. Container Path: ```/etc/prometheus/prometheus.yml```
      3. In EXEC tab of the running container (which opens a shell),
           ```
           /prometheus $
           /prometheus $ ls
           # This shows the database files of prometheus
           ```
   2. Using the following command on CLI from within PROJECT_DIR:
      1. ```docker run --name prometheus -p 9090:9090 -v prometheus-config.yml:/etc/prometheus/prometheus.yml prom/prometheus```
         OR  ```docker run --name prometheus -d -p 127.0.0.1:9090:9090 prom/prometheus``` in detached mode.
      2. From another terminal, let us connect to the container using shell:
           ```
           $> docker exec -it prometheus /bin/bash
           /prometheus $
           /prometheus $ ls
           # This shows the database files of prometheus
           ```

4. Launch the Prometheus UI on http://localhost:9090 and you will see the Prometheus page.
5. Check our application as a target in Prometheus by visiting the URL - http://localhost:9090/targets.  
   You should see something similar:

   ![Prometheus-Targets-Flyway.jpg](images%2FPrometheus-Targets-Flyway.jpg)
