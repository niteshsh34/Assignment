# Week 1 - Data Cleaning Assignment

### Assign1.ipynb
Jupyter Notebook containing all steps of data loading, exploration, cleaning, filtering, and feature creation using Pandas.

### cleaned_dataset.csv
Cleaned version of the dataset after handling missing values, removing duplicates, and creating derived features.

### Combined_dataset.csv
Original dataset used for analysis containing product information such as title, rating, price, discount, seller details, and category.

## Summary
In this assignment, the e-commerce product dataset was loaded into a Pandas DataFrame and explored using various data analysis techniques. The dataset structure, column names, data types, and sample records were examined to understand the available information.

Missing values were identified and handled appropriately. 
Numerical missing values were filled using suitable methods, while missing categorical values were replaced with "Not Available" to maintain data consistency. Duplicate records were checked and removed to improve data quality.

Basic data operations such as selecting specific columns and filtering products based on ratings were performed. 
The final_price column was cleaned by removing currency symbols and converting the values into numeric format for analysis.

Since the dataset did not contain a quantity column, a derived feature named engagement_value was created using final_price and ratings_count. 
This feature provides an estimate of product engagement based on customer interactions and product price.

Finally, the cleaned dataset was saved as a new CSV file named cleaned_dataset.csv for future analysis and use.
