package com.tsys.springflyway.web;

import com.tsys.springflyway.model.User;
import com.tsys.springflyway.model.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.OptimisticLockException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

@RestController
@RequestMapping("/users")
public class UserController {

  private static final Logger LOG = Logger.getLogger(UserController.class.getSimpleName());

  @Autowired
  private UserRepository repository;


  @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity create(@RequestBody User user) {
    LOG.info(String.format("Got POST Request for User = %s", user));
    return ResponseEntity.ok(repository.save(user));
  }

  @GetMapping()
  public ResponseEntity<List<User>> getAll() {
    final List<User> users = repository.findAll();
    return ResponseEntity.ok(users);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<User> getById(@PathVariable(required = true) Long id) {
    return ResponseEntity.of(repository.findById(id));
  }

  /*
   * With @PathVariable(required = false) we can map two paths this method:
   * 1. /users and
   * 2. /users/{id}
   * So, when PUT is called with /users, id is Optional.empty as its value is null and
   * when PUT is called with /users/{id}, it will have a value passed from the request as path variable.
   */
  @PutMapping(path = {"/{id}", ""}, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity update(@PathVariable(required = false) Optional<Long> id,
                               @RequestBody User user) {

    //  1. HTTP status code 200 OK for a successful PUT of an update to an existing resource.
    //     No response body needed. (Per Section 9.6, 204 No Content is even more appropriate.)
    //
    //  2. HTTP status code 201 Created for a successful PUT of a new resource, with the most specific
    //     URI for the new resource returned in the Location header field and any other relevant URIs
    //     and metadata of the resource echoed in the response body. (RFC 2616 Section 10.2.2)
    //
    //  3. HTTP status code 409 Conflict for a PUT that is unsuccessful due to a 3rd-party modification,
    //     with a list of differences between the attempted update and the current resource in the response
    //     body. (RFC 2616 Section 10.4.10)
    //
    //  4. HTTP status code 400 Bad Request for an unsuccessful PUT, with natural-language text
    //     (such as English) in the response body that explains why the PUT failed. (RFC 2616 Section 10.4)

    LOG.info(String.format("Got PUT Request for Id = %s, User = %s", id, user));
    Long userId = id.isEmpty() ? 0L : id.get();
    try {
      LOG.info(String.format("Getting User with Id = %d from database...", userId));
      final User userFromDatabase = repository.getReferenceById(userId);
      userFromDatabase.updateFrom(user);
      LOG.info(String.format("Updating in Database user with Id = %d ", userId));
      repository.save(userFromDatabase);
      return new ResponseEntity(HttpStatusCode.valueOf(200));
    } catch (EntityNotFoundException nonExistent) {
      LOG.info(String.format("Error: %s", nonExistent.getMessage()));
      try {
        LOG.info(String.format("Creating User in Database user = %s ", user));
        final User saved = repository.save(user);
        LOG.info(String.format("Created User in Database user = %s ", saved));
        return new ResponseEntity(saved, new LinkedMultiValueMap<String, String>() {{
          put("Location", List.of(URI.create(String.format("/users/%d", user.getId())).toString()));
        }}, HttpStatusCode.valueOf(201));
      } catch (OptimisticLockException ole) {
        LOG.info(String.format("Conflict - Could Not Update in Database user with Id = %d, Error Message = %s", userId, ole.getMessage()));
        return new ResponseEntity("{ \"error\" : \"You seem to have a stale version of the record\"}", HttpStatusCode.valueOf(409));
      }
    }
  }

  /*
   * With @PathVariable(required = false) we can map two paths this method:
   * 1. /users and
   * 2. /users/{id}
   * So, when DELETE is called with /users, id is Optional.empty as its value is null and
   * when DELETE is called with /users/{id}, it will have a value passed from the request as path variable.
   */
  @DeleteMapping(value = {"/{id}", ""})
  public void delete(@PathVariable(required = false) Optional<Long> id) {
    LOG.info(String.format("Got DELETE Request for Id = %s", id));
    id.ifPresentOrElse(userId -> {
      LOG.info(String.format("Deleting User with Id = %d", userId));
      repository.deleteById(userId);
    }, () -> {
      LOG.info(String.format("Deleting All Users"));
      repository.deleteAll();
    });
  }
}
