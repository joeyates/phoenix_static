# Strapi CMS Setup for PhoenixStatic Integration

This directory contains example configuration files and sample data for setting up Strapi CMS to work with the PhoenixStatic integration example.

## Content Type Definitions

### category-content-type.json
This file contains the JSON definition for the Category content type. You can use this to manually configure the content type in Strapi or as a reference.

### post-content-type.json  
This file contains the JSON definition for the Post content type with the required fields and relationships.

## Sample Data

### categories-sample.json
Sample categories that you can import into Strapi to test the integration.

### posts-sample.json
Sample blog posts with relationships to categories.

## Setup Instructions

1. Create a new Strapi project or use an existing one
2. In the Strapi admin, go to Content-Types Builder
3. Create the content types using the field definitions from the JSON files
4. Configure permissions for public access to the collections
5. Import or create sample content
6. Start the Phoenix application with the correct STRAPI_API_URL

## API Endpoints

Once set up, your Strapi instance should expose these endpoints:

- `GET /api/categories?populate=*` - Fetch all categories with relationships
- `GET /api/posts?populate=*` - Fetch all posts with relationships  
- `GET /api/categories/:id?populate=*` - Fetch a specific category
- `GET /api/posts/:id?populate=*` - Fetch a specific post

Make sure these endpoints are accessible to unauthenticated users by configuring the Public role permissions in Strapi.