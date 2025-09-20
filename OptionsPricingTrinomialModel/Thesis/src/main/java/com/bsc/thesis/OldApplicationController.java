package com.bsc.thesis;

import com.bsc.thesis.Options.vanilla.American;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import java.util.concurrent.ForkJoinPool;

public class OldApplicationController {
    @FXML private TextField input1;
    @FXML private TextField input2;
    @FXML private TextField input3;
    @FXML private TextField input4;
    @FXML private TextField input5;
    @FXML private TextField input6;
    @FXML private Button calculateButton;
    @FXML private Text resultText;

    @FXML private ComboBox<String> optionTypeComboBox;
    @FXML private VBox exoticParamsContainer;
    //@FXML private TextArea resultText;

    private static final ForkJoinPool pool = new ForkJoinPool();

    @FXML
    public void initialize() {
        optionTypeComboBox.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            updateUIForOptionType(newVal);
        });
    }

    private void updateUIForOptionType(String optionType) {
        // Hide exotic parameters unless exotic option is selected
        boolean isExotic = "Exotic Option".equals(optionType);
        exoticParamsContainer.setVisible(isExotic);
        exoticParamsContainer.setManaged(isExotic);
    }

    // TODO::
    /*
    @FXML
    private void calculateOptionPrice(ActionEvent event) {
        String optionType = optionTypeComboBox.getValue();

        double S0 = Double.parseDouble(input1.getText());
        double K = Double.parseDouble(input2.getText());
        // TODO: ... other common parameters

        double result = 0;
        switch(optionType) {
            case "European Call":
                result = calculateEuropeanCall(S0, K, ...);
                break;
            case "European Put":
                result = calculateEuropeanPut(S0, K, ...);
                break;
            // TODO: ... other cases
        }

        resultText.setText(String.format("%s Price: %.2f", optionType, result));
    }
     */

    @FXML
    private void handleCalculate(ActionEvent event) throws InterruptedException {
        String optionType = optionTypeComboBox.getValue();

        int N = Integer.parseInt(input4.getText());
        double K = Double.parseDouble(input2.getText());
        double S0 = Double.parseDouble(input1.getText());
        double r = Double.parseDouble(input3.getText());

        input5.setText("1.0/365, note: daily");
        input5.setDisable(true);
        double h = 1.0/365;

        double sigma = Double.parseDouble(input6.getText());;

        double u = sigma * Math.sqrt(3 * h);
        double p = 1.0/6;

        new American(K).calculateAmericanOptions(S0, N, r, p, sigma);

        long startTime = System.nanoTime();
        double optionPrice = new American(K).calculateAmericanOptions(S0, N, r, p, sigma);
        long endTime = System.nanoTime();

        resultText.setText(String.format("American Put Option Price: %.4f%n", optionPrice));

        System.out.printf("American Put Option Price: %.4f%n", optionPrice);
        System.out.printf("Execution time: %.3f ms%n", (endTime - startTime)/1e6);

        pool.shutdown();
    }

    @FXML
    private void handleSave(ActionEvent event) {
        // Implement saving to log file
        String content = optionTypeComboBox.getValue() + " - " + resultText.getText();
        // ... file saving logic
    }
}