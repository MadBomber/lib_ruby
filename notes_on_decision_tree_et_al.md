Looking at the three machine learning class implementations provided: `DecisionTree`, `RandomForestClassifier`, and `GradientBoostingClassifier`, several opportunities for improvement and refactoring can be identified. These improvements aim to enhance code clarity, efficiency, modularity, and maintainability.

### General Suggestions:
1. **Use More Descriptive Variable Names:** Enhancing variable naming for clarity. For instance, `l_data`, and `r_data` could be renamed to `left_data`, and `right_data`, making the code more readable.

2. **DRY Principle (Don't Repeat Yourself):** Identify repeated code segments and refactor them into separate methods or utilities. For example, the prediction aggregation logic appears similar in both `RandomForestClassifier` and `GradientBoostingClassifier`.

3. **Optimization and Data Processing:** 
    - Consider memory and performance implications when dealing with large datasets. For the `DecisionTree` class, feature values and thresholds computations could potentially be optimized.
    - When generating bootstrap samples, it might be beneficial to explore more efficient sampling techniques or parallelization, depending on the Ruby interpreter's capabilities.

### Specific Suggestions:

#### `DecisionTree` Class:

- **Refactor Feature Splitting Logic:** The nested loops for calculating the best split can be refactored for better readability. Extracting the inner loop into a method could improve maintainability.

- **Improve Feature Extraction in CSV Import:** The current method assumes the last column is the label. It'd be robust to explicitly define or identify the label column rather than relying on position.

#### `RandomForestClassifier` Class:

- **Method Extraction for Predictions Aggregation:** The prediction logic within `predict` could be extracted into a separate method to manage complexity and improve readability.

- **Parameter Validation:** Add checks to ensure `n_trees` and `max_depth` are positive integers, providing early warnings to users about improper usage.

#### `GradientBoostingClassifier` Class:

- **Refactor Training Method for Clarity:** The training method is quite dense. Breaking down the steps into smaller, well-named methods would enhance readability and maintainability. For example, computing pseudo-residuals and updating residuals could be extracted into their methods.

- **Enhance Initial Prediction Calculation:** The formula for initial prediction is critical. It's a good practice to check edge cases where `positive_probability` might be 0 or 1, leading to a division by zero in the logarithm calculation.

### Code Quality and Testing:
- **Unit Tests:** Ensure each class and method is covered by unit tests. This is fundamental for machine learning algorithms to verify their correctness under various scenarios and datasets.

- **Documentation:** Adding method-level documentation commenting on the purpose, inputs, outputs, and any side effects. Ruby's Yard or RDoc can be employed for this purpose, improving long-term maintainability and onboarding for new developers.

Implementing these suggestions would not only make your code more robust and maintainable but also potentially increase the performance and accuracy of your machine learning models.

