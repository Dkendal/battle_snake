it('can create a game', () => {
  cy.visit('/');

  cy.contains('New game').click();

  cy.get('#game_form_delay').type('{ctrl}a{backspace}0');
  cy.get('#game_form_height').type('{ctrl}a{backspace}5');
  cy.get('#game_form_width').type('{ctrl}a{backspace}5');
  cy.get('#game_form_snakes_0_url').type('http://example.com');
  cy.get('#game_form_snakes_1_url').type('http://localhost:5678/example');
  cy
    .get('#game_form_snakes_2_url')
    .type('http://localhost:5678/example{enter}');

  cy.contains('Show').click();

  cy.get('canvas').should('have.length', 2);

  cy
    .get('.healthbar-text')
    .should('contain', 'BATTLE★SNAKE')
    .and('have.length', 2);

  cy.get('.healthbar-text').should('contain', '100').and('have.length', 2);

  cy.get('.scoreboard-snake-alive').should('have.length', 2);

  cy.get('body').type('h');

  cy.get('.scoreboard-snake-dead').should('have.length.least', 1);
});
