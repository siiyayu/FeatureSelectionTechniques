# FeatureSelectionTechniques

### Steps:

#### Data preprocessing (preprocessing.ipynb):

Preprocessing data to exclude anomalies, conducting correlational and group mean analysis.
Getting insights for choosing the encoding method for the features, ordinal and categorical.

#### Creating pipelines for models evaluation and models evaluation (evaluating_models.ipynb):

Evaluation on cross-validation, averaging the feature importance across folds.
Choosing a XGBoost as a base model, we extract the feature importance based on information 
gains to compare with other models. Utilizing SHAP, which uses methods from graph theory and good 
for visualization. Testing models such as Lasso, ElasticNet, OLS, LinearRegression on 
different preprocessed features: with standard scaling and not, with ohe encoding and label encoding
for categorical features.

#### Conclusion:

When doing elastic_net on non-normalized numerical and label encoded 
features or lasso on normalized numerical and label encoded features, the duality gap is extremely
high with magnitude 10e8. The duality gap ensures that the solution is close to the optimal, both
in terms of the model's coefficients and its predictive performance, the resulting metrics 
are satisfactory.

When doing label encoding without scaling, OLS has only 32 p-values < 0.05. These features also 
sound as we see from correlation tables and other models.





