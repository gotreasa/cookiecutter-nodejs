Feature: API endpoints

    Scenario: Health endpoint
        Given the API endpoint /health

        When I call the endpoint
        Then the response is 200

    Scenario: Documentation endpoint
        Given the API endpoint /api-docs

        When I call the endpoint
        Then the response is 200
