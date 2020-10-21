package com.tsys.springflyway.web;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
