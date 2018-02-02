const { baseUrl } = require("../../cypress.json");

it("tests a snake", () => {
  cy.visit("/test");
  cy.get("input").type(`${baseUrl}/example`);
  cy.get("button").click();
  cy.contains("Failed:");
});

it("play a game", () => {
  cy.visit("/");

  cy.contains("New game").click();

  cy.get("#game_form_delay").type("{ctrl}a{backspace}0");
  cy.get("#game_form_height").type("{ctrl}a{backspace}5");
  cy.get("#game_form_width").type("{ctrl}a{backspace}5");
  cy.get("#game_form_dec_health_points").type("{ctrl}a{backspace}20");
  cy.get("#game_form_snakes_0_url").type("http://example.com");
  cy.get("#game_form_snakes_1_url").type(`${baseUrl}/example`);
  cy.get("#game_form_snakes_2_url").type(`${baseUrl}/example{enter}`);

  cy.contains("Show").click();

  cy.get("canvas").should("have.length", 2);

  cy.contains("Example Snake");
  cy.contains("http://example.com");

  cy.contains("100");

  cy.get("body").type("h");

  cy.contains("Dead");
});
