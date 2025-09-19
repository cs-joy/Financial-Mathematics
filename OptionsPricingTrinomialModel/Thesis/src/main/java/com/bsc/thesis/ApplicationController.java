package com.bsc.thesis;

import com.bsc.thesis.Options.American;
import com.bsc.thesis.Options.European_Unused;
import com.bsc.thesis.Options.Exotic;
import com.bsc.thesis.Options.vanilla.European;
import javafx.collections.FXCollections;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import javafx.util.Pair;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ApplicationController {

    // Common input fields
    @FXML private TextField stockPriceField;
    @FXML private TextField strikePriceField;
    @FXML private TextField riskFreeRateField;
    @FXML private TextField volatilityField;
    @FXML private TextField timeToMaturityField;
    @FXML private TextField numStepsField;
    @FXML private TextField timeStepField;
    @FXML private TextField upFactorField;
    @FXML private TextField prob_p_Field;

    // Option type selection
    @FXML private ComboBox<String> optionTypeComboBox;

    // Exotic option parameters
    @FXML private VBox exoticParamsContainer;
    @FXML private VBox barrierParams;
    @FXML private VBox asianParams;
    @FXML private VBox cliquetParams;
    @FXML private VBox compoundParams;
    @FXML private VBox bermudanParams;
    @FXML private VBox lookbackParams;

    @FXML private TextField barrierPriceField;
    @FXML private ComboBox<String> barrierTypeComboBox;
    @FXML private TextField numPeriodsField;
    @FXML private TextField localCapField;
    @FXML private TextField localFloorField;
    @FXML private TextField compoundStrikeField;
    @FXML private TextField compoundMaturityField;
    @FXML private TextField exerciseDatesField;

    // Action buttons and results
    @FXML private Button calculateButton;
    @FXML private Button saveButton;
    @FXML private Button clearButton;
    @FXML private TextArea resultTextArea;
    @FXML private Text statusText;

    @FXML private Text exoticTitle;

    private double lastCalculatedPrice = 0.0;
    private String lastCalculationDetails = "";

    @FXML
    public void initialize() {
//        System.out.println("asianParams is null: " + (asianParams == null));
//        System.out.println("barrierParams is null: " + (barrierParams == null));
//        System.out.println("cliquetParams is null: " + (cliquetParams == null));
//        System.out.println("compoundParams is null: " + (compoundParams == null));
//        System.out.println("bermudanParams is null: " + (bermudanParams == null));
//        System.out.println("lookbackParams is null: " + (lookbackParams == null));
        barrierParams.setVisible(false);
        asianParams.setVisible(false);
        cliquetParams.setVisible(false);
        compoundParams.setVisible(false);
        bermudanParams.setVisible(false);
        lookbackParams.setVisible(false);

        exoticTitle.setVisible(false);

        // Set up option type change listener
        optionTypeComboBox.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            updateUIForOptionType(newVal);
        });

        // Set default values
        setDefaultValues();

        // Set up barrier type combo box
        barrierTypeComboBox.setItems(FXCollections.observableArrayList(
                "Down-and-Out", "Down-and-In", "Up-and-Out", "Up-and-In"
        ));

        // Calculate time step and up factor when parameters change
        setupAutoCalculation();
    }

    private void setDefaultValues() {
        stockPriceField.setText("150.0");
        strikePriceField.setText("150.0");
        riskFreeRateField.setText("0.0425");
        volatilityField.setText("0.25");
        timeToMaturityField.setText("0.08219178082");
        numStepsField.setText("100");
        prob_p_Field.setText("0.4");

        // Auto-calculate time step and up factor
        calculateTreeParameters();
    }

    private void setupAutoCalculation() {
        // Recalculate tree parameters when relevant fields change
        timeToMaturityField.textProperty().addListener((obs, oldVal, newVal) -> calculateTreeParameters());
        numStepsField.textProperty().addListener((obs, oldVal, newVal) -> calculateTreeParameters());
        volatilityField.textProperty().addListener((obs, oldVal, newVal) -> calculateTreeParameters());
    }

    private void calculateTreeParameters() {
        try {
            double T = Double.parseDouble(timeToMaturityField.getText());
            int N = Integer.parseInt(numStepsField.getText());
            double sigma = Double.parseDouble(volatilityField.getText());
            double p = Double.parseDouble(prob_p_Field.getText());

            double h = T / N;
            double u = sigma * Math.sqrt(h / (2 * p));

            timeStepField.setText(String.format("%.6f", h));
            timeStepField.setDisable(true);
            upFactorField.setText(String.format("%.6f", u));
            upFactorField.setDisable(true);
        } catch (NumberFormatException e) {
            System.err.println(e.getMessage());
        }
    }

    private void updateUIForOptionType(String optionType) {
        // Hide all exotic parameter sections first
        if (barrierParams != null) {
            barrierParams.setVisible(false);
            barrierParams.setManaged(false);
        }
        if (asianParams != null) {
            asianParams.setVisible(false);
            asianParams.setManaged(false);
        }
        if (cliquetParams != null) {
            cliquetParams.setVisible(false);
            cliquetParams.setManaged(false);
        }

        if (compoundParams != null) {
            compoundParams.setVisible(false);
            compoundParams.setManaged(false);
        }

        if (bermudanParams != null) {
            bermudanParams.setVisible(false);
            bermudanParams.setManaged(false);
        }

        if (lookbackParams != null) {
            lookbackParams.setVisible(false);
            lookbackParams.setManaged(false);
        }


        // Show exotic container only for exotic options
        boolean isExotic = optionType != null &&
                (optionType.contains("Asian") || optionType.contains("Barrier") ||
                        optionType.contains("Cliquet") || optionType.contains("Compound") ||
                        optionType.contains("Lookback") || optionType.contains("Bermudan"));

        if (exoticParamsContainer != null) {
            exoticParamsContainer.setVisible(isExotic);
            exoticParamsContainer.setManaged(isExotic);
        }

        // Show specific parameters based on option type
        if (optionType != null) {
            exoticTitle.setVisible(true);
            switch (optionType) {
                case "Barrier Option":
                    if (barrierParams != null) {
                        barrierParams.setVisible(true);
                        barrierParams.setManaged(true);
                    }
                    break;
                case "Asian Option":
                    if (asianParams != null) {
                        asianParams.setVisible(true);
                        asianParams.setManaged(true);
                    }
                    break;
                case "Cliquet Option":
                    if (cliquetParams != null) {
                        cliquetParams.setVisible(true);
                        cliquetParams.setManaged(true);
                    }
                    break;
                case "Compound Option":
                    if (compoundParams != null) {
                        compoundParams.setVisible(true);
                        compoundParams.setManaged(true);
                    }
                    break;
                case "Bermudan Option":
                    if (bermudanParams != null) {
                        bermudanParams.setVisible(true);
                        bermudanParams.setManaged(true);
                    }
                    break;
                case "Lookback Option":
                    if (lookbackParams != null) {
                        lookbackParams.setVisible(true);
                        lookbackParams.setManaged(true);
                    }
                    break;
            }
        }
    }

    @FXML
    private void handleCalculate(ActionEvent event) {
        try {
            // get common parameters
            double S0 = Double.parseDouble(stockPriceField.getText());
            double K = Double.parseDouble(strikePriceField.getText());
            double r = Double.parseDouble(riskFreeRateField.getText());
            double sigma = Double.parseDouble(volatilityField.getText());
            double T = Double.parseDouble(timeToMaturityField.getText());
            int N = Integer.parseInt(numStepsField.getText());
            double p = Double.parseDouble(prob_p_Field.getText());
            double h = Double.parseDouble(timeStepField.getText());
            double u = Double.parseDouble(upFactorField.getText());

            String optionType = optionTypeComboBox.getValue();
            System.out.println("optionType: "+optionType);
            double result = 0.0;
            String PricingMethod = "";
            new European(K);

            // Calculate based on option type
            switch (optionType) {

                case "European Call":
                    result = European.calculateEuropeanOptions(true, S0, N, u, r, p, h);
                    PricingMethod = "Trinomial Tree";
                    break;
                case "European Put":
                    result = European.calculateEuropeanOptions(false, S0, N, u, r, p, h);
                    PricingMethod = "Trinomial Tree";
                    break;
                case "American Call":
                    double p1 = Math.random();
                    result = American.calculateAmericanPut(S0, K, r, N, p1, h, u, sigma);
                    PricingMethod = "Trinomial Tree";
                    break;
                case "American Put":
                    //double p = Math.random();
                    result = American.calculateAmericanPut(S0, K, r, N, p, h, u, sigma);
                    PricingMethod = "Trinomial Tree";
                    break;
                case "Asian Option":
                    result = Exotic.calculateAsianCall(S0, K, r, N, h, u, sigma);
                    PricingMethod = "Asian Arithmetic Average (Trinomial Tree)";
                    break;
                case "Barrier Option":
                    double barrier = Double.parseDouble(barrierPriceField.getText());
                    String barrierType = barrierTypeComboBox.getValue();
                    result = calculateBarrierOption(S0, K, barrier, r, N, h, u, sigma, barrierType);
                    PricingMethod = "Barrier Option (" + barrierType + ") - Trinomial Tree";
                    break;
                case "Cliquet Option":
                    int numPeriods = Integer.parseInt(numPeriodsField.getText());
                    double localCap = Double.parseDouble(localCapField.getText());
                    double localFloor = Double.parseDouble(localFloorField.getText());
                    result = Exotic.calculateCliquetOption(S0, K, localCap, localFloor, 0.3, -0.3, r, T, sigma, numPeriods);
                    PricingMethod = "Cliquet Option - Monte Carlo Simulation";
                    break;
                case "Compound Option":
                    double K1 = Double.parseDouble(compoundStrikeField.getText());
                    double T1 = Double.parseDouble(compoundMaturityField.getText());
                    result = Exotic.calculateCompoundOption(S0, K1, K, r, T1, T, sigma, true);
                    PricingMethod = "Compound Option (Call on Call) - Analytical";
                    break;
                case "Lookback Option":
                    result = Exotic.calculateLookbackCall(S0, r, N, h, u, sigma);
                    PricingMethod = "Lookback Option (Floating Strike) - Trinomial Tree";
                    break;
                case "Bermudan Option":
                    int[] exerciseDates = parseExerciseDates(exerciseDatesField.getText());
                    result = Exotic.calculateBermudanPut(S0, K, r, N, h, u, sigma, exerciseDates);
                    PricingMethod = "Bermudan Option - Trinomial Tree with Early Exercise";
                    break;
                default:
                    throw new IllegalArgumentException("Unknown option type: " + optionType);
            }

            lastCalculatedPrice = result;
            displayResults(result, optionType, PricingMethod, S0, K, r, sigma, T, N);

        } catch (NumberFormatException e) {
            showError("Please enter valid numeric values in all required fields.");
        } catch (Exception e) {
            showError("Maybe you forgot to choose an Option Type\n");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }

    private double calculateBarrierOption(double S0, double K, double barrier, double r,
                                          int N, double h, double u, double sigma, String barrierType) {
        switch (barrierType) {
            case "Down-and-Out":
                return Exotic.calculateBarrierDownOutCall(S0, K, barrier, r, N, h, u, sigma);
            case "Down-and-In":
                return Exotic.calculateBarrierDownInCall(S0, K, barrier, r, N, h, u, sigma);
            case "Up-and-Out":
                return Exotic.calculateBarrierOption(S0, K, barrier, r, N, h, u, sigma, false, false, true);
            case "Up-and-In":
                // Up-and-In = Vanilla - Up-and-Out
                double vanilla = European_Unused.calculateEuropeanCallTrinomial(S0, K, r, N, h, u, sigma);
                double upOut = Exotic.calculateBarrierOption(S0, K, barrier, r, N, h, u, sigma, false, false, true);
                return vanilla - upOut;
            default:
                throw new IllegalArgumentException("Unknown barrier type: " + barrierType);
        }
    }

    private int[] parseExerciseDates(String datesString) {
        if (datesString == null || datesString.trim().isEmpty()) {
            return new int[0];
        }
        try {
            String[] parts = datesString.split(",");
            int[] dates = new int[parts.length];
            for (int i = 0; i < parts.length; i++) {
                dates[i] = Integer.parseInt(parts[i].trim());
            }
            return dates;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid exercise dates format. Use comma-separated integers.");
        }
    }

    private void displayResults(double result, String optionType, String calculationMethod,
                                double S0, double K, double r, double sigma, double T, int N) {
        DecimalFormat df = new DecimalFormat("#,##0.0000");
        DecimalFormat percentFormat = new DecimalFormat("0.00%");

        String results = "=== OPTION PRICING RESULTS ===\n\n" +
                "Option Type: " + optionType + "\n" +
                "Calculation Method: " + calculationMethod + "\n\n" +
                "Input Parameters:\n" +
                "  Stock Price (S0): " + df.format(S0) + "\n" +
                "  Strike Price (K): " + df.format(K) + "\n" +
                "  Risk-free Rate (r): " + percentFormat.format(r) + "\n" +
                "  Volatility (σ): " + percentFormat.format(sigma) + "\n" +
                "  Time to Maturity (T): " + df.format(T) + " years\n" +
                "  Number of Steps (N): " + N + "\n\n" +
                "Calculated Option Price: " + df.format(result) + "\n\n" +
                "Calculation Time: " + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

        resultTextArea.setText(results);
        lastCalculationDetails = results;
        statusText.setText("Calculation completed successfully.");
    }

    @FXML
    private void handleSave(ActionEvent event) {
        if (lastCalculationDetails.isEmpty()) {
            showError("No calculation results to save. Please calculate first.");
            return;
        }

        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Save Calculation Results");
        fileChooser.getExtensionFilters().add(
                new FileChooser.ExtensionFilter("Text Files", "*.txt")
        );
        fileChooser.setInitialFileName("option_calculation_" +
                new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".txt");

        File file = fileChooser.showSaveDialog(getStage());
        if (file != null) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                writer.write(lastCalculationDetails);
                statusText.setText("Results saved to: " + file.getName());
            } catch (IOException e) {
                showError("Error saving file: " + e.getMessage());
            }
        }
    }

    @FXML
    private void handleClear(ActionEvent event) {
        // Clear all input fields
        stockPriceField.clear();
        strikePriceField.clear();
        riskFreeRateField.clear();
        volatilityField.clear();
        timeToMaturityField.clear();
        numStepsField.clear();
        timeStepField.clear();
        upFactorField.clear();
        prob_p_Field.clear();

        // Clear exotic parameters
        barrierPriceField.clear();
        numPeriodsField.clear();
        localCapField.clear();
        localFloorField.clear();
        compoundStrikeField.clear();
        compoundMaturityField.clear();
        exerciseDatesField.clear();

        // Clear results
        resultTextArea.clear();
        lastCalculatedPrice = 0.0;
        lastCalculationDetails = "";

        // Reset to defaults
        setDefaultValues();
        statusText.setText("Fields cleared. Ready for new calculation.");
    }

    private void showError(String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle("Error");
        alert.setHeaderText("Calculation Error");
        alert.setContentText(message);
        alert.showAndWait();
        statusText.setText("Error: " + message);
    }

    private Stage getStage() {
        return (Stage) calculateButton.getScene().getWindow();
    }

    // Helper method for testing
    public void testCalculation() {
        // Auto-populate some test values
        stockPriceField.setText("100.0");
        strikePriceField.setText("100.0");
        riskFreeRateField.setText("0.05");
        volatilityField.setText("0.2");
        timeToMaturityField.setText("1.0");
        numStepsField.setText("100");

        // Calculate tree parameters
        calculateTreeParameters();

        // Set option type and calculate
        optionTypeComboBox.getSelectionModel().select("European Call");
        handleCalculate(new ActionEvent());
    }

    @FXML
    private void handleSignIn(ActionEvent event) {
        showAuthDialog("Sign In");
    }

    @FXML
    private void handleSignUp(ActionEvent event) {
        showAuthDialog("Sign Up");
    }

    @FXML
    private void handleSubscribe(ActionEvent event) {
        showSubscriptionDialog();
    }

    private void showAuthDialog(String type) {
        Dialog<Pair<String, String>> dialog = new Dialog<>();
        dialog.setTitle(type);
        dialog.setHeaderText(type + " to ThalesZ Options Pricing Tools");

        ButtonType loginButtonType = new ButtonType(type, ButtonBar.ButtonData.OK_DONE);
        dialog.getDialogPane().getButtonTypes().addAll(loginButtonType, ButtonType.CANCEL);

        GridPane grid = new GridPane();
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(20, 150, 10, 10));

        TextField username = new TextField();
        username.setPromptText("Username");
        PasswordField password = new PasswordField();
        password.setPromptText("Password");

        grid.add(new Label("Username:"), 0, 0);
        grid.add(username, 1, 0);
        grid.add(new Label("Password:"), 0, 1);
        grid.add(password, 1, 1);

        if (type.equals("Sign Up")) {
            PasswordField confirmPassword = new PasswordField();
            confirmPassword.setPromptText("Confirm Password");
            grid.add(new Label("Confirm Password:"), 0, 2);
            grid.add(confirmPassword, 1, 2);
        }

        dialog.getDialogPane().setContent(grid);
        dialog.setResultConverter(dialogButton -> {
            if (dialogButton == loginButtonType) {
                return new Pair<>(username.getText(), password.getText());
            }
            return null;
        });

        dialog.showAndWait();
    }

    private void showSubscriptionDialog() {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("Subscription");
        alert.setHeaderText("Premium Features");
        alert.setContentText("Subscribe to access advanced analytics, real-time data, and premium support.");
        alert.showAndWait();
    }
}
