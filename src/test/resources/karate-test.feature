@REQ_MV-779 @HU779 @marvel_character @marvel_characters_api @Agente2 @E2 @marvel @id:1
Feature: MV-779 gestion de personajes de Marvel (microservicio para la gestión de personajes de Marvel)
  Background:
    * def config = read('classpath:data/configuration/configuration.json')
    * url config.urlBase
    * configure ssl = true
    * def generarHeaders =
      """
      function() {
        return {
          "Content-Type": "application/json",
          "Accept": "application/json"
        };
      }
      """
    * def headers = generarHeaders()
    * headers headers


  @GET @GetAllCharacters @SolicitudExitosa200
  Scenario: T-API-MV-779-CA001-Verificar que retorne los personajes 200 - karate
    Given path config.username,config.path
    When method GET
    Then status 200
    And match response == '#[]'

  @GET @GetCharacterById @SolicitudExitosa201
  Scenario:T-API-MV-779-CA002-Obtener un personaje de Marvel por ID 201 - Karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_marvel_character.json")
    * set newCharacter.name = newCharacter.name + '-' + java.util.UUID.randomUUID()
    Given path config.username,config.path
    And request newCharacter
    When method POST
    Then status 201
    * def characterId = response.id

    Given path config.username,config.path,characterId
    When method GET
    Then status 200
    And match response.id == characterId

  @GET @GetCharacterByIdError @SolicitudFallida404
  Scenario:T-API-MV-779-CA003-Obtener un personaje de Marvel por ID inexistente 404 - Karate
    Given path config.username,config.path,'999999999'
    When method GET
    Then status 404
    * print response
    And match response contains {  "error": "Character not found"  }

  @POST @CreateCharacter @SolicitudExitosa201
  Scenario:T-API-MV-779-CA004-Verificar la creación un personaje de Marvel exitoso 201 - karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_marvel_character.json")
    * set newCharacter.name = newCharacter.name + '-' + java.util.UUID.randomUUID()
    Given path config.username,config.path
    And request newCharacter
    When method POST
    Then status 201

  @POST @CreateCharacterError @SolicitudFallida400
  Scenario:T-API-MV-779-CA005-Verificar la creación un personaje de Marvel fallido 400 - karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_marvel_character.json")
    * set newCharacter.name = ''
    Given path config.username,config.path
    And request newCharacter
    When method POST
    Then status 400
    And match response.name == "Name is required"

  @POST @CreateCharacterError @SolicitudFallida400
  Scenario:T-API-MV-779-CA006-Verificar la creación un personaje de Marvel fallido con atributo faltante 400 - karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_marvel_character.json")
    * remove newCharacter.name
    Given path config.username,config.path
    And request newCharacter
    When method POST
    Then status 400
    And  response.name == "Name is required"

  @POST @CreateCharacterDuplicate @SolicitudFallida400 @SolicitudExitosa201
  Scenario: T-API-MV-779-CA007-Verificar la creación un personaje de Marvel duplicado 201 OR 400 - karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_duplicate_marvel_character.json")
    Given path config.username,config.path
    And request newCharacter
    When method POST
    * def statusCode = response.error == "Character name already exists" ? 400: 201
    Then match responseStatus == statusCode


  @PUT @updateCharacter @SolicitudExitosa200 @SolicitudExitosa201
  Scenario: T-API-MV-779-CA008-Verificar la actualización un personaje de Marvel exitoso 200 AND 201 - karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_marvel_character.json")
    * set newCharacter.name = newCharacter.name + '-' + java.util.UUID.randomUUID()
    Given path config.username,config.path
    And request newCharacter
    When method POST
    Then status 201
    * def characterId = response.id

    Given path config.username,config.path,characterId
    * def updatedCharacter = read("classpath:data/marvel_character/request_update_marvel_character.json")
    * set updatedCharacter.name = updatedCharacter.name + '-' + java.util.UUID.randomUUID()
    * set updatedCharacter.alterego = updatedCharacter.alterego + '-' + java.util.UUID.randomUUID()
    And request updatedCharacter
    When method PUT
    Then status 200
    And match response.id == characterId
    And match response.name == updatedCharacter.name
    And match response.description == updatedCharacter.description
    And match response.alterego == updatedCharacter.alterego
    And match response.powers == updatedCharacter.powers

  @PUT @updateCharacter @SolicitudFallida404
  Scenario: T-API-MV-779-CA009-Verificar la actualización un personaje de Marvel que no existe 404 - karate
    * def updatedCharacter = read("classpath:data/marvel_character/request_update_marvel_character.json")
    Given path config.username,config.path,"999"
    And request updatedCharacter
    When method PUT
    Then status 404
    And match response.error ==  "Character not found"

  @PUT @updateCharacter @SolicitudFallida400
  Scenario: T-API-MV-779-CA010-Verificar la actualización un personaje de Marvel con atributo faltante 400 - karate
    * def updatedCharacter = read("classpath:data/marvel_character/request_update_marvel_character.json")
    * remove updatedCharacter.name
    Given path config.username,config.path,"999"
    And request updatedCharacter
    When method PUT
    Then status 400
    And match response.name == "Name is required"

  @DELETE @DeleteCharacter @SolicitudExitosa201 @SolicitudExitosa204
  Scenario: T-API-MV-779-CA011-Verificar la eliminación un personaje de Marvel exitoso 201 AND 204 - karate
    * def newCharacter = read("classpath:data/marvel_character/request_creation_marvel_character.json")
    * set newCharacter.name = newCharacter.name + '-' + java.util.UUID.randomUUID()
    Given path config.username,config.path
    And request newCharacter
    When method POST
    Then status 201
    * def characterId = response.id

    Given path config.username,config.path,characterId
    When method DELETE
    Then status 204

  @DELETE @DeleteCharacterError @SolicitudFallida404
  Scenario: T-API-MV-779-CA012-Verificar la eliminación un personaje de Marvel que no existe 404 - karate
    Given path config.username,config.path,"999"
    When method DELETE
    Then status 404
    And match response.error ==  "Character not found"

