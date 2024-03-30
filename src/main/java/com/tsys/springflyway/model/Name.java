package com.tsys.springflyway.model;

import jakarta.persistence.Embeddable;

@Embeddable
public class Name {
  public final String first;
  public final String middle;
  public final String last;

  private Name() {
    this("", "", "");
  }

  public Name(String first, String middle, String last) {
    this.first = first;
    this.middle = middle;
    this.last = last;
  }

  public String full() {
    if (null == middle)
      return String.format("%s %s", first, last.toUpperCase());

    return String.format("%s %c. %s", first, Character.toUpperCase(middle.charAt(0)), last.toUpperCase());
  }

  @Override
  public boolean equals(Object o) {
    if (this == o)
      return true;

    if (o == null || getClass() != o.getClass())
      return false;

    Name name = (Name) o;

    if (!first.equals(name.first))
      return false;
    if (!middle.equals(name.middle))
      return false;

    return last.equals(name.last);
  }

  @Override
  public int hashCode() {
    int result = first.hashCode();
    result = 31 * result + middle.hashCode();
    result = 31 * result + last.hashCode();
    return result;
  }

  @Override
  public String toString() {
    return "Name{" +
        "first='" + first + '\'' +
        ", middle='" + middle + '\'' +
        ", last='" + last + '\'' +
        '}';
  }
}
