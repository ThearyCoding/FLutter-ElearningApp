import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PokeAPIController extends GetxController {
  final String apiUrl = "https://pokeapi.co/api/v2/pokemon?limit=250";

  // Observable variable to store the response
  Rx<http.Response?> pokemonResponse = Rx<http.Response?>(null);

  // Method to fetch Pokémon data
  Future<void> fetchPokemon() async {
    try {
      http.Response response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Update the observable with the response
        pokemonResponse.value = response;
      } else {
        // Request failed, handle error
        print("Failed to fetch Pokémon. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Exception occurred during request
      print("Exception thrown: $e");
    }
  }
}
