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

| ID	  | Bean Name	              | Usage                                                                  |
|--------|---------------------------|------------------------------------------------------------------------|
| build  | BuildInfoContributor	  | Exposes build information.                                             |
| env	  | EnvironmentInfoContributor| Exposes any property from the Environment whose name starts with info. |
| git	  | GitInfoContributor	      | Exposes Git related information.                                       |
| java	  | JavaInfoContributor	      | Exposes Java runtime information.                                      |

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

## Customizing the ```/metrics``` Endpoint

We know that ```/metrics``` endpoint publishes information about OS and JVM as well as application-level metrics.  
In order to gather custom metrics, we have support for:
* ```Counter``` - a counter is a cumulative metric that represents a single value that can only be
  incremented/decremented or be reset to zero on restart, e.g. how many times feature A has been used.
* ```Gauge``` - a gauge is a metric that represents a single numerical snapshot of data that can arbitrarily go up
  and down, e.g. how many users are registered-users.
* ```Timer``` - to measure time. There are also histograms and summaries e.g. how much time does request to an
  endpoint take on average.

Spring Boot 2.0 uses Micrometer for metrics in a Spring application.  Micrometer is now part of the Actuator’s
dependencies, so we should be good to go as long as the Actuator dependency is in the classpath.

**What is Micrometer?**

Micrometer provides a simple facade over the instrumentation clients for the most popular observability systems,
allowing you to instrument your JVM-based application code without vendor lock-in. Think SLF4J, but for observability:
* Vendor-neutral application metrics façade
* Application metrics recorded by Micrometer are intended to be used to observe, alert, and react to
  the current/recent operational state of your environment.
* Metrics Façade for Amazon Cloud Watch, Elastic, Prometheus

**Micrometer Concepts**

Let us look at the abstractions Micrometer provides:
* ```Meter``` - is the interface for collecting a set of measurements or metrics about the application.
* ```MeterRegistry``` Meters in Micrometer are created from and held in a MeterRegistry.
  Each supported monitoring system has an implementation of ```MeterRegistry```.
* ```SimpleMeterRegistry``` - it holds the latest value of each meter in memory and does not export the data anywhere.
  It is autowired in a Spring Boot application.
* ```@Timed``` - An annotation that frameworks can use to add timing support to either specific types
  of end-point methods that serve web request or to all methods.

[//]: # (//In the example below, we have added @Timed annotation to the API method which exposes timing metrics on the endpoint.)

We now implement custom metrics into the ```/metrics``` end-point.

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

## Customizing the ```/health``` Endpoint
The /health endpoint is used to check the health or state of the running application.
It is often used by monitoring software to alert someone when a production system goes down
or gets unhealthy for other reasons, e.g., connectivity issues with our DB, lack of disk space, etc.

By default, unauthorized users can only see status information when they access over HTTP.  The status ```UP```
indicates that the application is running.  This is a derived-status from an evaluation of the health of
many components called **Health Indicators** in a specific order.

The status will show ```DOWN``` if any of those health indicator components
are "unhealthy" - for instance, the database is not reachable.

```json
{
  "status" : "UP"
}
```

The information exposed by the health endpoint depends on the
```management.endpoint.health.show-details``` and ```management.endpoint.health.show-components```
properties which can be configured with one of the following values:

```
# Allowed values are never, when-authorized, always
management.endpoint.health.show-components = always
management.endpoint.health.show-details = when-authorized
```

Now point the browser to ```/health``` endpoint and  you should see
something similar as response:

```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

Now, you can change the property value ```management.endpoint.health.show-details = always``` and it will
give all the details.  Check it out for yourself.

If you have database, in your application, then break the network connection of the DB or shut the database down and 
then come back to this end-point.  You should see something similar:

```json
{
  "status": "DOWN",
  "components": {
    "db": {
      "status": "DOWN"
    },
    "diskSpace": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

The aggregate status is - ```DOWN``` because one of the components, in this case, 
the database connection is ```DOWN```.  Bring it back up and the overall status and the 
individual DB status will turn ```UP```.

Just as we had tests for the sub-components of ```/info``` endpoint, we add tests for the
sub-components of the ```/health``` end-point.

```java
public class SpringFlywayActuatorTest {

   ...
   ...
   
  @Test
  public void actuatorHealthEndpointHasPingStatus() {
    // Given-When
    final ResponseEntity<Map> response = client.getForEntity("/actuator/health", Map.class);

    // Then
    final Map<String, String> components = (Map<String, String>) response.getBody().get("components");
    assertTrue(components.containsKey("ping"));
  }
  
  @Test
  public void actuatorHealthEndpointHasDiskSpaceStatus() {
    // Given-When
    final ResponseEntity<Map> response = client.getForEntity("/actuator/health", Map.class);

    // Then
    final Map<String, String> components = (Map<String, String>) response.getBody().get("components");
    assertTrue(components.containsKey("diskSpace"));
  }
  
  @Test
  public void actuatorHealthEndpointHasDatabaseStatus() {
    // Given-When
    final ResponseEntity<Map> response = client.getForEntity("/actuator/health", Map.class);

    // Then
    final Map<String, String> components = (Map<String, String>) response.getBody().get("components");
    assertTrue(components.containsKey("db"));
  }
}
```

Spring Boot Actuator comes with several out-of-box health indicators like:

* ```DataSourceHealthIndicator``` - health check by this indicator creates a connection to a database 
   and issues a simple query - ```select 1 from dual``` to ensure that the ```DataSource``` is working.
* ```MailHealthIndicator```
* ```RedisHealthIndicator``` 
etc...

Each of the above indicators is a Spring bean that implements the ```HealthIndicator``` interface and checks the 
health of that component.  

### Custom Health Indicator, Health Aggregator and Health Contributor

First, let us understand the difference between an ```HealthIndicator```, ```HealthAggregator``` and a ```HealthContributor```.

* Health Indicator is a component that returns a health status (UP, DOWN, etc). 
  This component could perform an action, like calling an API or querying a database 
  or service.

* Health Aggregator, on the other hand processes the various Health Status (of the Health Indicators) 
  and produces a general Health Status for the application.

#### Custom Health Indicator
Let us assume that our microservice depends on another upstream service for 
some part of its functionality to be fulfilled.  Any unavailablity of this remote service 
will make our functionality useless.  So, we will develop a ```ServiceHealthIndicator``` which
pings the dependent service and gives us an indication of its health.

**NOTE:** The services that provide data or functionality to other services are referred to as 
"upstream" services, while the services that consume data or functionality from other services 
are called "downstream" services.  In architectural terms the words - "upstream" and "downstream" 
refer to the direction of data-flow between microservices.  This data-flow can be thought of 
as a stream flowing downstream from the source (upstream) to the destination (downstream).  

Let's create a package ```com.tsys.springflyway.service.spring```.  In the ```service``` package, we will have our 
service interface and the corresponding implementation, which are not interested in right now.  Let's create 
```com.tsys.springflyway.service.spring.ServiceHealthIndicator``` as Spring Bean and make it implement 
the ```HealthIndicator``` interface.  By annotating it as ```@Component```, we automatically register our custom 
```HealthIndicator``` to report the health of a component or subsystem. 

```java
package com.tsys.springflyway.service.spring;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component("upstream-service")
public class ServiceHealthIndicator implements HealthIndicator {

   @Override
   public Health health() {
      return null;
   }
}
```

Also, in the corresponding ```test``` folder, we will add a parallel package hierarchy and a Spec as 
```ServiceHealthIndicatorSpecs``` with a first specification to make sure that it shows health 
status as ```UP```.

```java
package com.tsys.springflyway.service.spring;

import org.junit.jupiter.api.Test;
import org.springframework.boot.actuate.health.Health;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

public class ServiceHealthIndicatorSpecs {

  private ServiceHealthIndicator serviceHealthIndicator = new ServiceHealthIndicator();
  @Test
  public void isUP() {
    final Health statusUP = new Health.Builder().up().build();
    assertThat(serviceHealthIndicator.health(), is(statusUP));
  }
}
```

Obviously, the test fails when we run this, so we write minimal code to make the test green:

```java
package com.tsys.springflyway.service.spring;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component("upstream-service")
public class ServiceHealthIndicator implements HealthIndicator {

  @Override
  public Health health() {
    return Health.up().build();
  }
}
```

Now, lets compile and run the application, and point the browser to - 
```http://localhost:8080/actuator/health```, you should see something similar:

```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    },
    "upstream-service": {
      "status": "UP"
    }
  },
}
```

It shows, our entry ```"upstream-service"``` with ```"status" : "UP"```.

Also, add a corresponding test in the ActuatorTest class:

```java
public class SpringFlywayActuatorTest {

  @Test
  public void actuatorHealthEndpointHasUpstreamServiceStatus() {
    // Given-When
    final ResponseEntity<Map> response = client.getForEntity("/actuator/health", Map.class);

    // Then
    final Map<String, String> components = (Map<String, String>) response.getBody().get("components");
    assertTrue(components.containsKey("upstream-service"));
  }
}
```

Next, we modify the existing ```ServiceHealthIndicatorSpecs``` test to talk to a mock service host and port.  
For this, we inject them in the constructor of the ```ServiceHealthIndicator```:

```java
@ExtendWith(MockitoExtension.class)
public class ServiceHealthIndicatorSpecs {
   private URL serviceHost = mock(URL.class);

   private Socket socket = mock(Socket.class);

   private int servicePort = 8080;

   private ServiceHealthIndicator serviceHealthIndicator = new ServiceHealthIndicator(serviceHost, servicePort) {
      @Override
      Socket createSocket(String host, int servicePort) throws IOException {
         return socket;
      }
   };

   @Test
   public void isUPWhenUpStreamSystemIsUp() {
      final Health statusUP = new Health.Builder().up().build();
      assertThat(serviceHealthIndicator.health(), is(statusUP));
   }
}
```

and the production code will change to make the test green:

```java
public class ServiceHealthIndicator implements HealthIndicator {

  private static final Logger LOG = Logger.getLogger(ServiceHealthIndicator.class.getName());

  private final URL serviceHost;
  private final int servicePort;

  public ServiceHealthIndicator(URL serviceHost, int servicePort) {
     this.serviceHost = serviceHost;
     this.servicePort = servicePort;
  }

  @Override
  public Health health() {
     try (Socket socket = createSocket(serviceHost.getHost(), servicePort)) {
     } catch (Exception e) {
       LOG.severe(String.format("Failed to connect to: %s:%d",serviceHost.getHost(), servicePort));
       return Health.down()
               .withDetail("error", e.getMessage())
               .build();
     }
     return Health.up().build();
   }

   Socket createSocket(String host, int servicePort) throws IOException {
      return new Socket(host, servicePort);
   }
}
```

Now, if we run the application after the tests are green, we will still fail because
we have not yet initialized the bean constructor in production with service host and port.
In order to do that we will add the following properties in
```application-development.properties```

```properties
application.remote.service.host = http://localhost
application.remote.service.port = 8080
```

and in the constuctor let spring inject them.

```java
public class ServiceHealthIndicator implements HealthIndicator {

   private static final Logger LOG = Logger.getLogger(ServiceHealthIndicator.class.getName());

   private final URL serviceHost;
   private final int servicePort;

   public ServiceHealthIndicator(@Value("${application.remote.service.host}") URL serviceHost,
                                 @Value("${application.remote.service.port}") int servicePort) {
      this.serviceHost = serviceHost;
      this.servicePort = servicePort;
   }
   
   ...
   ...
}
```
Now start the application and hit the browser with ```http://localhost:8080/actuator/health``` URL
and you should see:

```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    },
    "upstream-service": {
      "status": "UP"
    }
  },
}
```
But if you run all the tests you will find that the ```actuatorHealthEnpointWorks()``` test in the
```SpringBootActuatorTest``` fails as it is not able to find http://localhost:8080 during the test run.  
This happens because the ```@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)``` we are
testing this url against the static port: ```8080``` injected from  ```application.remote.service.port``` in the  
```application.properties``` file.  So, we need to inject the random port number which the Spring Boot Test
starts.  Here is how we do it.  Add the below to the ```SpringBootActuatorTest``` leaving other tests as is:

```java
public class SpringFlywayActuatorTest {
  
   ...
   ...
   
   // Inject which port we were assigned from the above random port
   @Value("${local.server.port}")
   private int port;

   @Autowired
   private ApplicationContext context;

   @BeforeEach
   public void setupServiceHealthIndicator() throws NoSuchFieldException, IllegalAccessException {
      final ServiceHealthIndicator bean = context.getBean(ServiceHealthIndicator.class);
      final Field portField = ServiceHealthIndicator.class.getDeclaredField("servicePort");
      portField.setAccessible(true);
      portField.set(bean, port);
   }

   ...
   ...   
   
}
```

Now, all the tests will be green.


We add the remaining success test where it can connect to the upstream service:

```java
public class ServiceHealthIndicatorSpecs {
  private URL serviceHost = mock(URL.class);

  private int servicePort = 8080;

  @Test
  public void isUPWhenUpStreamSystemIsUp() {
    // Given
    ServiceHealthIndicator serviceHealthIndicator = new ServiceHealthIndicator(serviceHost, servicePort) {
      @Override
      Socket createSocket(String host, int port) throws IOException {
        return mock(Socket.class);
      }
    };

    // When
    final Health actual = serviceHealthIndicator.health();

    // Then
    final Health statusUP = new Health.Builder().up().build();
    assertThat(actual, is(statusUP));
  }

  @Test
  public void isDownWhenUpstreamSystemIsDown() {
    final String errorMessage = String.format("Failed to connect to: %s:%d", serviceHost, servicePort);
    ServiceHealthIndicator serviceHealthIndicator = new ServiceHealthIndicator(serviceHost, servicePort) {
      @Override
      Socket createSocket(String host, int port) throws IOException {

        throw new IOException(errorMessage);
      }
    };

    // When
    final Health actual = serviceHealthIndicator.health();

    // Then
    final Health statusDOWN = new Health.Builder()
        .down()
        .withDetail("error", errorMessage)
        .build();
    assertThat(actual, is(statusDOWN));
  }
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

