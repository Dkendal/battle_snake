it.only('can create a game', () => {
  cy.visit('/');

  cy.contains('New game').click();

  cy.get('#game_form_snakes_0_url').type('http://example.com');
  cy.get('#game_form_snakes_1_url').type('http://localhost:5678/example');
  cy
    .get('#game_form_snakes_2_url')
    .type('http://localhost:5678/example{enter}');

  cy.contains('Show').click();

  cy.get('canvas').should('have.length', 2)

  cy.contains('BATTLE★SNAKE')
});
