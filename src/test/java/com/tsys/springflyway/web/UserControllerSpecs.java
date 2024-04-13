package com.tsys.springflyway.web;

import com.tsys.springflyway.model.User;
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
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.List;
import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Tags({
    @Tag("In-Process"),
    @Tag("ComponentTest")
})
@TestPropertySource("/test.properties")
public class UserControllerSpecs {

  @Autowired
  private UserController userController;

  @Autowired
  private TestRestTemplate client;

  private User krishna = makeUser("Krishna V. Yadav", "krishna@heaven.com");

  @Test
  public void getsAllUsers() {
    // Given
    final ResponseEntity<User> response = client.postForEntity("/users", krishna, User.class);
    User krishnaSaved = response.getBody();

    // When
    final ResponseEntity<List> allUsers = client.getForEntity("/users", List.class);

    // Then
    assertThat(allUsers.getStatusCode(), is(HttpStatus.OK));
    assertThat(allUsers.getHeaders().getContentType(), is(new MediaType("application", "json")));

    Map<String, ?> actual = (Map<String, ?>) allUsers.getBody().get(0);
    assertThat(actual.get("id"), is(krishnaSaved.getId().intValue()));
    assertThat(actual.get("version"), is(krishnaSaved.getVersion().intValue()));
    assertThat(actual.get("name"), is(krishnaSaved.getName()));
    assertThat(actual.get("email"), is(krishnaSaved.getEmail()));
  }

  private User makeUser(String name, String email) {
    User user = new User();
    user.setName(name);
    user.setEmail(email);
    return user;
  }
}
