it.only('can create a game', () => {
  cy.server().route('GET', 'http://example.com/test', {name: 'sup'});
  cy.visit('/');

  cy.contains('New game').click();

  cy.get('#game_form_snakes_0_url').type('http://example.com/test{enter}');

  cy.contains('Show').click();
});
