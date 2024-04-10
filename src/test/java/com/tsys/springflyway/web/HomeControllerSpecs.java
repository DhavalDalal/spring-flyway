package com.tsys.springflyway.web;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Tags;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.nio.charset.Charset;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.is;

@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Tags({
    @Tag("In-Process"),
    @Tag("ComponentTest")
})
public class HomeControllerSpecs {

  @Autowired
  private HomeController homeController;

  @Autowired
  private TestRestTemplate client;

  @Test
  public void homesToIndexPage() {
    // Given-When
    final ResponseEntity<String> indexPage = client.getForEntity("/", String.class);

    // Then
    assertThat(indexPage.getStatusCode(), is(HttpStatus.OK));
    assertThat(indexPage.getHeaders().getContentType(), is(new MediaType("text", "html", Charset.forName("UTF-8"))));
    final String body = indexPage.getBody();
    assertThat(body, org.hamcrest.Matchers.startsWith("<!DOCTYPE html>"));
    assertThat(body, containsString("Spring Flyway Demo"));
  }

  @Test
  public void health() {
    // Given-When
    final ResponseEntity<String> response = client.getForEntity("/ping", String.class);

    // Then
    assertThat(response.getStatusCode(), is(HttpStatus.OK));
    assertThat(response.getBody(), is("{ \"PONG\" : \"HomeController is running fine!\" }"));
  }
}
