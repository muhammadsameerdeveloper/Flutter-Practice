import 'package:flutter/material.dart';

class PeriodicTable extends StatelessWidget {
  const PeriodicTable({super.key});

  static const List<List<String>> elements = [
    ['H', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'He'],
    [
      'Li',
      'Be',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      'B',
      'C',
      'N',
      'O',
      'F',
      'Ne',
    ],
    [
      'Na',
      'Mg',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      'Al',
      'Si',
      'P',
      'S',
      'Cl',
      'Ar',
    ],
    [
      'K',
      'Ca',
      'Sc',
      'Ti',
      'V',
      'Cr',
      'Mn',
      'Fe',
      'Co',
      'Ni',
      'Cu',
      'Zn',
      'Ga',
      'Ge',
      'As',
      'Se',
      'Br',
      'Kr',
    ],
    [
      'Rb',
      'Sr',
      'Y',
      'Zr',
      'Nb',
      'Mo',
      'Tc',
      'Ru',
      'Rh',
      'Pd',
      'Ag',
      'Cd',
      'In',
      'Sn',
      'Sb',
      'Te',
      'I',
      'Xe',
    ],
    [
      'Cs',
      'Ba',
      'La',
      'Hf',
      'Ta',
      'W',
      'Re',
      'Os',
      'Ir',
      'Pt',
      'Au',
      'Hg',
      'Tl',
      'Pb',
      'Bi',
      'Po',
      'At',
      'Rn',
    ],
    [
      'Fr',
      'Ra',
      'Ac',
      'Rf',
      'Db',
      'Sg',
      'Bh',
      'Hs',
      'Mt',
      'Ds',
      'Rg',
      'Cn',
      'Nh',
      'Fl',
      'Mc',
      'Lv',
      'Ts',
      'Og',
    ],
  ];

  static const List<String> lanthanides = [
    'Ce',
    'Pr',
    'Nd',
    'Pm',
    'Sm',
    'Eu',
    'Gd',
    'Tb',
    'Dy',
    'Ho',
    'Er',
    'Tm',
    'Yb',
    'Lu',
  ];

  static const List<String> actinides = [
    'Th',
    'Pa',
    'U',
    'Np',
    'Pu',
    'Am',
    'Cm',
    'Bk',
    'Cf',
    'Es',
    'Fm',
    'Md',
    'No',
    'Lr',
  ];

  static const Map<String, int> atomicNumbers = {
    'H': 1,
    'He': 2,
    'Li': 3,
    'Be': 4,
    'B': 5,
    'C': 6,
    'N': 7,
    'O': 8,
    'F': 9,
    'Ne': 10,
    'Na': 11,
    'Mg': 12,
    'Al': 13,
    'Si': 14,
    'P': 15,
    'S': 16,
    'Cl': 17,
    'Ar': 18,
    'K': 19,
    'Ca': 20,
    'Sc': 21,
    'Ti': 22,
    'V': 23,
    'Cr': 24,
    'Mn': 25,
    'Fe': 26,
    'Co': 27,
    'Ni': 28,
    'Cu': 29,
    'Zn': 30,
    'Ga': 31,
    'Ge': 32,
    'As': 33,
    'Se': 34,
    'Br': 35,
    'Kr': 36,
    'Rb': 37,
    'Sr': 38,
    'Y': 39,
    'Zr': 40,
    'Nb': 41,
    'Mo': 42,
    'Tc': 43,
    'Ru': 44,
    'Rh': 45,
    'Pd': 46,
    'Ag': 47,
    'Cd': 48,
    'In': 49,
    'Sn': 50,
    'Sb': 51,
    'Te': 52,
    'I': 53,
    'Xe': 54,
    'Cs': 55,
    'Ba': 56,
    'La': 57,
    'Ce': 58,
    'Pr': 59,
    'Nd': 60,
    'Pm': 61,
    'Sm': 62,
    'Eu': 63,
    'Gd': 64,
    'Tb': 65,
    'Dy': 66,
    'Ho': 67,
    'Er': 68,
    'Tm': 69,
    'Yb': 70,
    'Lu': 71,
    'Hf': 72,
    'Ta': 73,
    'W': 74,
    'Re': 75,
    'Os': 76,
    'Ir': 77,
    'Pt': 78,
    'Au': 79,
    'Hg': 80,
    'Tl': 81,
    'Pb': 82,
    'Bi': 83,
    'Po': 84,
    'At': 85,
    'Rn': 86,
    'Fr': 87,
    'Ra': 88,
    'Ac': 89,
    'Th': 90,
    'Pa': 91,
    'U': 92,
    'Np': 93,
    'Pu': 94,
    'Am': 95,
    'Cm': 96,
    'Bk': 97,
    'Cf': 98,
    'Es': 99,
    'Fm': 100,
    'Md': 101,
    'No': 102,
    'Lr': 103,
    'Rf': 104,
    'Db': 105,
    'Sg': 106,
    'Bh': 107,
    'Hs': 108,
    'Mt': 109,
    'Ds': 110,
    'Rg': 111,
    'Cn': 112,
    'Nh': 113,
    'Fl': 114,
    'Mc': 115,
    'Lv': 116,
    'Ts': 117,
    'Og': 118,
  };

  Color getColor(String symbol) {
    if (['H', 'C', 'N', 'O', 'P', 'S', 'Se'].contains(symbol)) {
      return const Color(0xFF22C55E);
    }

    if (['He', 'Ne', 'Ar', 'Kr', 'Xe', 'Rn', 'Og'].contains(symbol)) {
      return const Color(0xFF8B5CF6);
    }

    if (['Li', 'Na', 'K', 'Rb', 'Cs', 'Fr'].contains(symbol)) {
      return const Color(0xFFEF4444);
    }

    if (['Be', 'Mg', 'Ca', 'Sr', 'Ba', 'Ra'].contains(symbol)) {
      return const Color(0xFFF59E0B);
    }

    if (lanthanides.contains(symbol) || actinides.contains(symbol)) {
      return const Color(0xFFEC4899);
    }

    return const Color(0xFF3B82F6);
  }

  Widget elementCard(String symbol, BuildContext context) {
    final number = atomicNumbers[symbol] ?? 0;
    final color = getColor(symbol);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF172554),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 55,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Atomic Number: $number',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chemical Element',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        width: 62,
        height: 68,
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.3),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '$number',
                style: const TextStyle(fontSize: 9, color: Colors.white70),
              ),
            ),
            Text(
              symbol,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget elementRow(List<String> row, BuildContext context) {
    return Row(
      children: row.map((symbol) {
        if (symbol.isEmpty) {
          return const SizedBox(width: 68);
        }

        return elementCard(symbol, context);
      }).toList(),
    );
  }

  Widget separateRow(List<String> row, BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 213),
        ...row.map((symbol) => elementCard(symbol, context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071426),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071426),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Periodic Table',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),

            const Text(
              '118 Chemical Elements',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 25),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  ...elements.map((row) => elementRow(row, context)),

                  const SizedBox(height: 25),

                  separateRow(lanthanides, context),

                  separateRow(actinides, context),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Tap Any Element To Explore',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
