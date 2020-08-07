package com.tsys.springflyway;

import com.tsys.springflyway.model.User;
import com.tsys.springflyway.model.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
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
  public User getById(@PathVariable(required = true) long id) {
    return repository.findById(id)
        .orElseThrow(() -> new NotFoundException(String.format("User with id => %d does not exist!", id)));
  }

  @DeleteMapping("/{id}")
  public void delete(@PathVariable(required = true) long id) {
    repository.deleteById(id);
  }

  @DeleteMapping
  public void deleteAll() {
    repository.deleteAll();
  }
}
