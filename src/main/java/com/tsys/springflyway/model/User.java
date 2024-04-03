package com.tsys.springflyway.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity // This tells Hibernate to make a table out of this class
@Table(name = "users")
@AllArgsConstructor
@Data
@NoArgsConstructor

// To start with the user object has only 3 fields
// We use Hibernate ddl-auto: create mechanism to create the
// tables: user and hibernate_sequence as a part of this initial
// state.
public class User {
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  private Long id;

  @Version
  private Long version;
  
  private String name;

  private String email;

  // Step 1. Comment line - No birthdate field
  // Step 2. We make schema changes to add birthdate field
  //         and uncomment the line below:
  //  private Date birthdate;

  public void updateFrom(User user) {
    name = user.name;
    email = user.email;
    //birthdate = user.birthdate;
  }
}
