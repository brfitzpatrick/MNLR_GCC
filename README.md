## Multinomial Logistic Regression for Ground Cover Classification

### Predictions from Elastic Net Regularized Multinomial Logistic Regression

Model tuned by 10 fold cross validation with a 10 by 10 tuning parameter grid. 

Tuning Parameter Estimates: 
 * alpha = 1 (i.e. a LASSO solution is selected)
 * lambda = 3.39855e-05

75.74% of pixels classified correctly by this model.

Within class classification accuracy:

|Ground Cover Category | Pixels in Category| % of Total Pixels | % of Pixels in Category Correctly Classified|
|:---------------|--------:|----------:|-----------:|
|Cotton          |    72450|      29.60|       92.82|
|Sorghum         |    66751|      27.27|       86.24|
|Pasture_natural |    27479|      11.23|       80.07|
|Bare_soil       |    26172|      10.69|       92.46|
|Peanut          |    17868|       7.30|       50.12|
|Maize           |    12986|       5.31|       29.24|
|Wheat           |    10778|       4.40|        9.30|
|Barley          |     3813|       1.56|        9.97|
|Sunflower       |     2573|       1.05|        0.35|
|Oat             |     1513|       0.62|        0.00|
|Mungbean        |     1225|       0.50|       18.20|
|Leucaena        |     1145|       0.47|        0.00|



Estimated Coefficients: 

<img src="http://i.imgur.com/vUmWlHg.png" alt="Image" width="600" height="1000" border="2" /></a>


