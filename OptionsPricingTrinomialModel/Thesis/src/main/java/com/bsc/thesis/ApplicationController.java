package com.bsc.thesis;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.text.Text;

public class ApplicationController {
    @FXML private TextField input1;
    @FXML private TextField input2;
    @FXML private TextField input3;
    @FXML private TextField input4;
    @FXML private TextField input5;
    @FXML private TextField input6;
    @FXML private Button calculateButton;
    @FXML private Text resultText;

    @FXML
    public void initialize() {

    }

    @FXML
    private void handleCalculate() {
        // Example calculation - sum all numeric inputs
        try {
            double sum = 0;
            sum += parseDouble(input1.getText());
            sum += parseDouble(input2.getText());
            sum += parseDouble(input3.getText());
            sum += parseDouble(input4.getText());
            sum += parseDouble(input5.getText());
            sum += parseDouble(input6.getText());

            resultText.setText(String.format("Calculation Result: %.2f", sum));
        } catch (NumberFormatException e) {
            resultText.setText("Please enter valid numbers in all fields");
        }
    }

    private double parseDouble(String text) {
        if (text == null || text.trim().isEmpty()) {
            return 0;
        }
        return Double.parseDouble(text.trim());
    }
}