package com.tsys.springflyway;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.TestPropertySource;

import javax.sql.DataSource;

import java.sql.SQLException;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
@TestPropertySource("/test.properties")
class SpringFlywayApplicationTests {

	@Autowired
	private ApplicationContext context;

	@Autowired
	private DataSource dataSource;

	@Test
	public void contextLoads() throws SQLException {
		assertNotNull(context);
		assertNotNull(dataSource);
		final String url = dataSource.getConnection().getMetaData().getURL();
		assertThat(url, is("jdbc:mysql://localhost:3306/flywaydemo"));
	}
}
