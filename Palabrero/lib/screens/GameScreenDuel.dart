import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameScreenDuel extends StatefulWidget {
  final bool isDuelMode;

  const GameScreenDuel({super.key, required this.isDuelMode});

  @override
  State<GameScreenDuel> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreenDuel> {
  static const int boardSize = 9;
  static const int playerTilesCount = 7;
  int player1Score = 0;
  int player2Score = 0;

  final Map<String, int> letterFrequency = {
    'A': 9, 'B': 2, 'C': 2, 'D': 4, 'E': 12, 'F': 2, 'G': 3, 'H': 2, 'I': 9,
    'J': 1, 'K': 1, 'L': 4, 'M': 2, 'N': 6, 'O': 8, 'P': 2, 'Q': 1, 'R': 6,
    'S': 4, 'T': 6, 'U': 4, 'V': 2, 'W': 2, 'X': 1, 'Y': 2, 'Z': 1
  };

  final Map<String, int> letterScores = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1, 'F': 4, 'G': 2, 'H': 4, 'I': 1,
    'J': 8, 'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1, 'P': 3, 'Q': 10, 'R': 1,
    'S': 1, 'T': 1, 'U': 1, 'V': 4, 'W': 4, 'X': 8, 'Y': 4, 'Z': 10
  };

  List<String?> boardTiles = List<String?>.filled(boardSize * boardSize, null);
  List<String> player1Tiles = [];
  List<String> player2Tiles = [];
  List<String> selectedTilesForWord = [];
  late List<String> letterPool;
  String? draggableWord;
  bool isHorizontal = true;
  String? selectedBoardWord;
  int? selectedBoardWordStartIndex;
  bool isPlayer1Turn = true;
  int playerDiscardsRemaining = 3;

  @override
  void initState() {
    super.initState();
    _initializeLetterPool();
    _generateRandomTiles();
  }

  void _initializeLetterPool() {
    letterPool = [];
    letterFrequency.forEach((letter, count) {
      letterPool.addAll(List.filled(count, letter));
    });
    letterPool.shuffle(Random());
  }

  void _generateRandomTiles() {
    if (letterPool.isNotEmpty) {
      final neededTiles = playerTilesCount - (isPlayer1Turn ? player1Tiles.length : player2Tiles.length);
      final newTiles = letterPool.take(neededTiles).toList();
      if (mounted) {
        setState(() {
          if (isPlayer1Turn) {
            player1Tiles.addAll(newTiles);
          } else {
            player2Tiles.addAll(newTiles);
          }
          letterPool.removeRange(0, min(neededTiles, letterPool.length));
        });
      }
    } else {
      _showErrorMessage('No hay más letras disponibles en el pool.');
    }
  }

  Future<bool> validateWord(String word) async {
    try {
      final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List && data.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Error al validar palabra: $e');
    }
    return false;
  }

  Future<void> tryPlaceWordOnBoard() async {
    if (selectedTilesForWord.isEmpty) return;

    String word = selectedTilesForWord.join();
    bool isValid = await validateWord(word);

    if (isValid && mounted) {
      setState(() {
        draggableWord = word;
      });
    } else if (mounted) {
      _returnTilesToPlayer();
      _showInvalidWordMessage(word);
    }
  }

  void _placeWordOnBoard(int startIndex) {
    if (draggableWord == null || !mounted) return;

    int wordLength = draggableWord!.length;
    int row = startIndex ~/ boardSize;
    int col = startIndex % boardSize;

    // Verificar si las celdas están vacías
    for (int i = 0; i < wordLength; i++) {
      int index = isHorizontal ? startIndex + i : startIndex + (i * boardSize);
      if (index >= boardSize * boardSize || boardTiles[index] != null) {
        _showInvalidPlacementMessage();
        return;
      }
    }

    if (isHorizontal ? col + wordLength > boardSize : row + wordLength > boardSize) {
      _showInvalidPlacementMessage();
      return;
    }

    int wordScore = 0;
    for (int i = 0; i < wordLength; i++) {
      String letter = draggableWord![i];
      wordScore += letterScores[letter] ?? 0;
    }

    if (mounted) {
      setState(() {
        for (int i = 0; i < wordLength; i++) {
          int index = isHorizontal ? startIndex + i : startIndex + (i * boardSize);
          boardTiles[index] = draggableWord![i];
        }
        // Sumar la puntuación al jugador correspondiente
        if (isPlayer1Turn) {
          player1Score += wordScore;
        } else {
          player2Score += wordScore;
        }
        draggableWord = null;
        _updatePlayerTiles();
        _endTurn();
      });
    }

    // Verificar si alguien ha ganado
    if (mounted && (player1Score >= 20 || player2Score >= 20)) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    if (!mounted) return;

    String winner = player1Score >= 20 ? 'Jugador 1' : 'Jugador 2';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Felicidades!'),
          content: Text('$winner ha ganado.'),
          actions: <Widget>[
            TextButton(
              child: Text('Volver a jugar'),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  _resetGame();
                }
              },
            ),
            TextButton(
              child: Text('Volver al dashboard'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Asume que el dashboard es la pantalla anterior
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      player1Score = 0;
      player2Score = 0;
      boardTiles = List<String?>.filled(boardSize * boardSize, null);
      player1Tiles.clear();
      player2Tiles.clear();
      selectedTilesForWord.clear();
      _initializeLetterPool();
      _generateRandomTiles();
    });
  }

  void _endTurn() {
    if (mounted) {
      setState(() {
        isPlayer1Turn = !isPlayer1Turn;
        playerDiscardsRemaining = 3;
        _generateRandomTiles();
      });
    }
  }

  void _discardSelectedTiles() {
    if (selectedTilesForWord.isNotEmpty && playerDiscardsRemaining > 0 && mounted) {
      setState(() {
        String tileToDiscard = selectedTilesForWord.last;
        letterPool.add(tileToDiscard);
        if (isPlayer1Turn) {
          player1Tiles.remove(tileToDiscard);
        } else {
          player2Tiles.remove(tileToDiscard);
        }
        selectedTilesForWord.remove(tileToDiscard);
        letterPool.shuffle(Random());
        _generateRandomTiles();
        playerDiscardsRemaining--;
      });
    } else {
      _showErrorMessage('No te quedan descartes en este turno.');
    }
  }

  void _returnTilesToPlayer() {
    if (mounted) {
      setState(() {
        if (isPlayer1Turn) {
          player1Tiles.addAll(selectedTilesForWord);
        } else {
          player2Tiles.addAll(selectedTilesForWord);
        }
        selectedTilesForWord.clear();
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInvalidWordMessage(String word) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$word" no es una palabra válida.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInvalidPlacementMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay suficiente espacio para colocar la palabra.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updatePlayerTiles() {
    if (mounted) {
      setState(() {
        if (isPlayer1Turn) {
          player1Tiles.removeWhere((tile) => selectedTilesForWord.contains(tile));
        } else {
          player2Tiles.removeWhere((tile) => selectedTilesForWord.contains(tile));
        }
        selectedTilesForWord.clear();
        _generateRandomTiles();
      });
    }
  }

  void _selectWordOnBoard(int startIndex) {
    if (!isPlayer1Turn) return;
    int row = startIndex ~/ boardSize;
    int col = startIndex % boardSize;

    String horizontalWord = _getWordInDirection(row, col, 0, 1);
    String verticalWord = _getWordInDirection(row, col, 1, 0);

    if (horizontalWord.length > verticalWord.length) {
      if (mounted) {
        setState(() {
          selectedBoardWord = horizontalWord;
          selectedBoardWordStartIndex = row * boardSize + (col - (horizontalWord.length - 1));
          isHorizontal = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          selectedBoardWord = verticalWord;
          selectedBoardWordStartIndex = (row - (verticalWord.length - 1)) * boardSize + col;
          isHorizontal = false;
        });
      }
    }
  }

  String _getWordInDirection(int row, int col, int rowIncrement, int colIncrement) {
    String word = '';
    int i = 0;

    while (row >= 0 && col >= 0 && row < boardSize && col < boardSize && boardTiles[row * boardSize + col] != null) {
      row -= rowIncrement;
      col -= colIncrement;
    }

    row += rowIncrement;
    col += colIncrement;

    while (row >= 0 && col >= 0 && row < boardSize && col < boardSize && boardTiles[row * boardSize + col] != null) {
      word += boardTiles[row * boardSize + col]!;
      row += rowIncrement;
      col += colIncrement;
    }

    return word;
  }

  Future<void> _extendWordOnBoard({bool extendForward = true}) async {
    if (selectedBoardWord == null || selectedBoardWordStartIndex == null || selectedTilesForWord.isEmpty) {
      _showErrorMessage('Selecciona una palabra y letras para extender.');
      return;
    }

    String newWord = extendForward ? selectedBoardWord! + selectedTilesForWord.join() : selectedTilesForWord.join() + selectedBoardWord!;
    bool isValid = await validateWord(newWord);

    if (!isValid) {
      _showInvalidWordMessage(newWord);
      return;
    }

    int startIndex = selectedBoardWordStartIndex!;
    int wordLength = newWord.length;
    int row = startIndex ~/ boardSize;
    int col = startIndex % boardSize;

    if (!extendForward) {
      startIndex -= isHorizontal ? selectedTilesForWord.length : selectedTilesForWord.length * boardSize;
    }

    if (isHorizontal ? col + wordLength > boardSize || startIndex < 0 : row + wordLength > boardSize || startIndex < 0) {
      _showInvalidPlacementMessage();
      return;
    }

    if (mounted) {
      setState(() {
        for (int i = 0; i < wordLength; i++) {
          int index = isHorizontal ? startIndex + i : startIndex + (i * boardSize);
          boardTiles[index] = newWord[i];
        }
        selectedBoardWord = null;
        selectedBoardWordStartIndex = null;
        _updatePlayerTiles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color.fromARGB(255, 82, 104, 246),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 82, 104, 246),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jugador 1: $player1Score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              isPlayer1Turn ? 'Turno del Jugador 1' : 'Turno del Jugador 2',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 82, 104, 246),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jugador 2: $player2Score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: boardSize * boardSize,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _selectWordOnBoard(index),
                    child: DragTarget<String>(
                      onAccept: (data) => _placeWordOnBoard(index),
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: boardTiles[index] == null
                                ? const Color.fromARGB(255, 83, 146, 75)
                                : Colors.brown[700],
                            border: Border.all(color: Colors.black, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              boardTiles[index] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[400],
            child: Column(
              children: [
                if (selectedTilesForWord.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 5,
                      children: selectedTilesForWord.map((tile) {
                        return Chip(
                          label: Text(tile),
                          onDeleted: () {
                            setState(() {
                              selectedTilesForWord.remove(tile);
                              if (isPlayer1Turn) {
                                player1Tiles.add(tile);
                              } else {
                                player2Tiles.add(tile);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                Wrap(
                  spacing: 5,
                  children: (isPlayer1Turn ? player1Tiles : player2Tiles).map((tile) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTilesForWord.add(tile);
                          if (isPlayer1Turn) {
                            player1Tiles.remove(tile);
                          } else {
                            player2Tiles.remove(tile);
                          }
                        });
                      },
                      child: Chip(
                        label: Text(tile),
                      ),
                    );
                  }).toList(),
                ),
                if (draggableWord != null)
                  Column(
                    children: [
                      Text(
                        'Palabra: $draggableWord',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Dirección:'),
                          Switch(
                            value: isHorizontal,
                            onChanged: (value) {
                              setState(() {
                                isHorizontal = value;
                              });
                            },
                          ),
                          Text(isHorizontal ? 'Horizontal' : 'Vertical'),
                        ],
                      ),
                      Draggable<String>(
                        data: draggableWord,
                        feedback: Material(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: const Color.fromARGB(255, 82, 104, 246).withOpacity(0.5),
                            child: Text(
                              draggableWord!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: const Color.fromARGB(255, 82, 104, 246),
                          child: Text(
                            draggableWord!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (selectedBoardWord != null)
                  Column(
                    children: [
                      Text(
                        'Palabra seleccionada: $selectedBoardWord',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _extendWordOnBoard(extendForward: true),
                            child: const Text('Extender hacia adelante'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _extendWordOnBoard(extendForward: false),
                            child: const Text('Extender hacia atrás'),
                          ),
                        ],
                      ),
                    ],
                  ),
                Container(
                  width: double.infinity,
                  color: Colors.grey[600],
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: selectedTilesForWord.isNotEmpty && playerDiscardsRemaining > 0 ? _discardSelectedTiles : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 82, 104, 246),
                        ),
                        child: const Text(
                          'Descartar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: selectedTilesForWord.isNotEmpty ? tryPlaceWordOnBoard : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                        ),
                        child: const Text(
                          'Validar y colocar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}