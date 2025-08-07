# Strapi CMS Integration Example

This example demonstrates how to integrate **Strapi CMS** with **PhoenixStatic** to generate static blog pages at compile time. The example fetches content from a Strapi API and generates optimized static HTML pages for blog posts, categories, and a blog index.

## Features

- **Static Page Generation**: Blog content is fetched from Strapi at compile time and converted into static HTML pages
- **Content Types**: Handles Posts and Categories with relationships
- **Multiple Page Types**: Generates individual post pages, category pages, and a blog index
- **HTTP Client**: Uses HTTPoison for reliable API communication with Strapi
- **Error Handling**: Graceful degradation when Strapi API is unavailable
- **Environment Configuration**: Flexible configuration for different environments
- **Efficient Recompilation**: Only recompiles when Strapi content changes

## Content Structure

### Posts Collection (Strapi)
```json
{
  "title": "String (required)",
  "content": "Rich Text", 
  "slug": "String (required, unique)",
  "publishedAt": "DateTime",
  "category": "Relation (belongs to Category)"
}
```

### Categories Collection (Strapi)
```json
{
  "name": "String (required)",
  "slug": "String (required, unique)", 
  "description": "Text"
}
```

## Generated Routes

The example generates the following static routes:

- `/blog` - Blog index page listing all posts
- `/posts/{slug}` - Individual blog post pages
- `/categories/{slug}` - Category pages showing posts in that category

## Prerequisites

1. **Elixir** >= 1.14
2. **Phoenix** >= 1.7
3. **Strapi CMS** instance with the required content types

## Setting Up Strapi

### 1. Install and Start Strapi

```bash
# Create a new Strapi project
npx create-strapi-app@latest my-strapi-blog --quickstart

# Navigate to the project
cd my-strapi-blog

# Start Strapi
npm run develop
```

Strapi will be available at `http://localhost:1337`

### 2. Create Content Types

#### Categories Collection Type

1. Go to **Content-Types Builder** in Strapi admin
2. Create a new **Collection Type** called "Category"
3. Add the following fields:
   - `name` (Text, required)
   - `slug` (Text, required, unique)
   - `description` (Text, optional)

#### Posts Collection Type

1. Create a new **Collection Type** called "Post"
2. Add the following fields:
   - `title` (Text, required)
   - `content` (Rich Text, required)
   - `slug` (Text, required, unique)
   - `publishedAt` (DateTime, optional)
   - `category` (Relation: Post belongs to one Category)

### 3. Configure Permissions

1. Go to **Settings > Users & Permissions > Roles**
2. Edit the **Public** role
3. Enable **find** and **findOne** permissions for both **Category** and **Post** collections

### 4. Add Sample Content

Create a few categories and posts to test the integration:

**Sample Category:**
- Name: "Technology"
- Slug: "technology" 
- Description: "Posts about technology and software development"

**Sample Post:**
- Title: "Getting Started with Phoenix"
- Slug: "getting-started-with-phoenix"
- Content: "Phoenix is a productive web framework..."
- Category: Technology
- Published At: (current date)

## Running the Example

### 1. Install Dependencies

```bash
cd examples/strapi_integration
mix deps.get
```

### 2. Configure Strapi API URL

Set the Strapi API URL in your environment:

```bash
export STRAPI_API_URL=http://localhost:1337
```

Or update the configuration in `config/dev.exs`:

```elixir
config :strapi_example,
  strapi_api_url: "http://localhost:1337"
```

### 3. Start the Phoenix Server

```bash
mix phx.server
```

The application will be available at `http://localhost:4000`

### 4. Visit the Generated Pages

- **Home**: http://localhost:4000 - Introduction and overview
- **Blog Index**: http://localhost:4000/blog - List of all blog posts
- **Sample Post**: http://localhost:4000/posts/getting-started-with-phoenix
- **Sample Category**: http://localhost:4000/categories/technology

## How It Works

### 1. Source Module (`StrapiSource`)

The `StrapiExampleWeb.StrapiSource` module implements the `PhoenixStatic.Source` behaviour:

- **`list_pages/0`**: Fetches posts and categories from Strapi API and converts them into `PhoenixStatic.Page` structs
- **`last_modified/0`**: Returns the latest modification timestamp to enable efficient recompilation

### 2. Content Fetching

The source module makes HTTP requests to Strapi's REST API:

```
GET /api/categories?populate=*
GET /api/posts?populate=*
```

### 3. Page Generation

For each content item, the source generates static HTML pages:

- **Blog Index**: Overview page with links to all posts
- **Post Pages**: Individual pages with full post content, category links, and navigation
- **Category Pages**: Pages showing all posts in a specific category

### 4. Controller and View

- **`BlogController`**: Uses `PhoenixStatic.Controller` to automatically generate action functions for each page
- **`BlogHTML`**: Uses `PhoenixStatic.View` to render the pre-generated HTML content

### 5. Routing

The `Router` uses `PhoenixStatic.Routes` to automatically generate routes for all static pages.

## Architecture

```
┌─────────────────┐    HTTP     ┌─────────────────┐
│   Strapi CMS    │ ◄─────────── │  StrapiSource   │
│                 │              │                 │
│ - Posts         │              │ - fetch_posts() │
│ - Categories    │              │ - fetch_cats()  │
└─────────────────┘              └─────────────────┘
                                          │
                                          ▼
                                 ┌─────────────────┐
                                 │ PhoenixStatic   │
                                 │                 │
                                 │ - Page structs  │
                                 │ - Static HTML   │
                                 └─────────────────┘
                                          │
                                          ▼
                                 ┌─────────────────┐
                                 │ Phoenix App     │
                                 │                 │
                                 │ - BlogController│
                                 │ - BlogHTML      │
                                 │ - Routes        │
                                 └─────────────────┘
```

## Error Handling

The example includes robust error handling:

- **API Failures**: If Strapi is unavailable, the source returns an empty page list to allow compilation to continue
- **JSON Parsing**: Handles malformed JSON responses gracefully
- **Missing Content**: Provides fallbacks for missing or incomplete content
- **Network Timeouts**: Configures reasonable timeouts for HTTP requests

## Configuration Options

### Environment Variables

- `STRAPI_API_URL`: URL of your Strapi instance (default: `http://localhost:1337`)
- `SECRET_KEY_BASE`: Phoenix secret key for production
- `PHX_HOST`: Hostname for production deployment
- `PORT`: Port number for the Phoenix server

### Application Configuration

In `config/config.exs`:

```elixir
config :strapi_example,
  strapi_api_url: "http://localhost:1337"
```

## Production Deployment

### 1. Environment Setup

Ensure the following environment variables are set:

```bash
export STRAPI_API_URL=https://your-strapi-instance.com
export SECRET_KEY_BASE=your_secret_key
export PHX_HOST=your-domain.com
```

### 2. Build Release

```bash
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release
```

### 3. Run Release

```bash
PHX_SERVER=true _build/prod/rel/strapi_example/bin/strapi_example start
```

## Customization

### Extending Content Types

To add new content types:

1. Create the content type in Strapi
2. Update `StrapiSource.list_pages/0` to fetch the new content
3. Add page building functions for the new content type
4. Update the `fetch_*` and `get_*_last_modified` functions

### Styling and Templates

The example uses inline CSS for simplicity. For production use:

1. Add a proper CSS framework (Tailwind, Bootstrap, etc.)
2. Create reusable Phoenix components
3. Extract HTML templates into separate files
4. Add responsive design and accessibility features

### Caching

For better performance, consider:

1. Adding Redis caching for Strapi responses
2. Implementing ETags for HTTP caching
3. Using CDN for static asset delivery
4. Adding database caching for frequently accessed content

## Testing

Run the test suite:

```bash
mix test
```

For testing with a real Strapi instance:

```bash
STRAPI_API_URL=http://localhost:1337 mix test
```

## Troubleshooting

### Common Issues

1. **Connection Refused**: Ensure Strapi is running on the configured URL
2. **Empty Pages**: Check Strapi permissions for public access to collections
3. **Compilation Errors**: Verify all dependencies are installed with `mix deps.get`
4. **Missing Routes**: Ensure content exists in Strapi and has the required fields

### Debug Mode

Enable debug logging in `config/dev.exs`:

```elixir
config :logger, :console, level: :debug
```

This will show detailed HTTP request/response information.

## Performance Considerations

- **Compile Time**: Content is fetched only during compilation, not at runtime
- **Memory Usage**: All page content is held in memory during compilation
- **Build Time**: Larger content sets will increase build time
- **HTTP Timeouts**: Configured for 10 seconds to handle slow Strapi responses

## License

This example is provided as-is for educational purposes. Feel free to adapt it for your own projects.

## Contributing

If you find issues or have improvements, please submit a pull request to the main PhoenixStatic repository.