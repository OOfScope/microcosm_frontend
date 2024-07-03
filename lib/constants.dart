import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const Color primaryColor = Color(0xFF2697FF);
const Color secondaryColor = Color(0xFF2A2D3E);
const Color bgColor = Color(0xFF212332);

const double defaultPadding = 16.0;

const double answerFontSize = 28;

const double tissueDescriptionFontSize = 18;

const int correctAnswerScore = 10;
const int wrongAnswerScore = 0;

// 1: (0, 0, 255),    # Carcinoma
// 2: (255, 0, 0),    # Necrosis
// 3: (0, 255, 0),    # Tumor Stroma
// 4: (0, 255, 255),  # Others

Map<int, String> tissueTypes = <int, String>{
  1: 'Carcinoma',
  2: 'Necrosis',
  3: 'Tumor Stroma',
  4: 'Others',
};

Map<int, String> gameTitles = <int, String>{
  1: 'Quiz',
  2: 'Drag & Drop',
  3: 'Memory',
  4: 'Select The Area',
};

Map<int, Color> tissueColors = <int, Color>{
  1: Colors.blue,
  2: Colors.red,
  3: Colors.green,
  4: Color.fromRGBO(0, 255, 255, 1),
};

Map<int, String> tissueDescription = <int, String>{
  1: 'Carcinoma is a type of cancer that begins in the epithelial cells, which are the cells that line the inside and outside surfaces of the body. It can occur in various organs, including the skin, lungs, and breast, among others. Carcinomas are characterized by the uncontrolled growth of abnormal cells that can invade nearby tissues and spread to other parts of the body.',
  2: 'Necrosis refers to the death of cells or tissues in the body due to factors such as lack of blood supply, injury, or infection. This process can lead to the destruction of affected tissues and is often associated with inflammation. Necrotic tissue typically appears as discolored, often blackened, and may have a soft, liquefied texture.',
  3: 'Tumor stroma is the supportive tissue around a tumor, consisting of various components such as connective tissue, blood vessels, and immune cells. The stroma provides structural support and nutrients to the tumor but can also play a role in tumor growth and progression by facilitating communication between cancer cells and the surrounding environment.',
  4: "This class includes all non-malignant tissues, such as normal, benign, and inflammatory tissues. These tissues are characterized by their lack of cancerous cells and include healthy tissue, tissue with non-cancerous growths, and tissue affected by inflammation or infection. They play various roles in the body's normal function and response to injury or disease.",
};
