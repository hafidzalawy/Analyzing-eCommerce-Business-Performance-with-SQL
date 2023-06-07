# Analyzing-eCommerce-Business-Performance-with-SQL

## Background Project 
Measuring business performance is very important for every company. It will help you assess your current market, access new customers and find new business opportunities. This time, I will analyze business performance of an e-Commerce by reviewing it customer growth, product quality, and payment methods.

The dataset that will be used today was provided by Rakamin Academy. It has information of 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allows viewing an order from multiple dimensions : from order status, price, payment and freight performance to customer location, product attributes and finally reviews written by customers. I will perform the analysis using PostgreSQL and create the visualization using Google Data Studio 

## Data Preparation 
Before starting data processing, the first step that must be done is to prepare the raw data into structured and ready-to-process data. The following eCommerce dataset consists of 8 datasets that will interact with each other. So the steps taken are as follows:

- Create a new database and its tables for the data that has been prepared by paying attention to the data type of each column.
- Importing csv data into the database by paying attention to the dataset storage path.
- Create entity relationships between tables, based on the schema in Figure 1. Data Relationship. 
- Then export the Entity Relationship Diagram (ERD) in the form of an image by setting the data type and naming the columns between interconnected tables.
