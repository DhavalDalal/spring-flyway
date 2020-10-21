package com.tsys.springflyway.web;

import com.tsys.springflyway.model.User;
import com.tsys.springflyway.model.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

  @Autowired
  private UserRepository repository;

  @GetMapping
  public List<User> allUsers() {
    return (List<User>) repository.findAll();
  }

  @PostMapping
  public void create(@RequestBody User user) {
    repository.save(user);
  }

  @GetMapping("/{id}")
  public ResponseEntity<User> getById(@PathVariable(required = true) Long id) {
    return ResponseEntity.of(repository.findById(id));
  }

  @DeleteMapping("/{id}")
  public void delete(@PathVariable(required = true) Long id) {
    repository.deleteById(id);
  }

  @DeleteMapping
  public void deleteAll() {
    repository.deleteAll();
  }
}
