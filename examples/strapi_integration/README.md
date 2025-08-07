# Phoenix Static + Strapi CMS Integration Example

This example demonstrates how to use `phoenix_static` with Strapi CMS as a content source to generate static pages at compile time.

## Overview

This example shows how to:

- **Fetch content from Strapi REST API** using Req HTTP client
- **Generate static pages** for blog posts, categories, and blog index
- **Handle relationships** between content types (Posts ↔ Categories)
- **Implement proper error handling** and fallbacks for API failures
- **Configure environment-based** Strapi API URLs and API keys
- **Track last modification times** for efficient recompilation

## Features Demonstrated

### Content Types
- **Posts**: Blog posts with title, content, slug, publication date, and category relationship
- **Categories**: Blog categories with name, slug, and description

### Generated Pages
- **Individual blog posts** at `/posts/{slug}`
- **Category pages** at `/categories/{slug}` with filtered posts
- **Blog index page** at `/blog` with recent posts and category list
- **Home page** at `/` with example documentation

### Phoenix Static Integration
- **Source Module**: `StrapiWeb.StrapiSource` implements `PhoenixStatic.Source` behavior
- **Controller**: `StrapiWeb.BlogController` uses `PhoenixStatic.Controller`
- **View**: `StrapiWeb.BlogHTML` uses `PhoenixStatic.View`
- **Routes**: Automatically generated using `PhoenixStatic.Routes`

## Prerequisites

### Strapi CMS Setup

1. **Install Strapi** (requires Node.js):
   ```bash
   npx create-strapi-app@latest my-strapi-project --quickstart
   ```

2. **Create Content Types** in Strapi Admin Panel (`http://localhost:1337/admin`):

   **Categories Collection:**
   - `name` (Text, required)
   - `slug` (UID, required, target field: name)
   - `description` (Text, long text)

   **Posts Collection:**
   - `title` (Text, required)
   - `slug` (UID, required, target field: title)
   - `content` (Rich text, required)
   - `publishedAt` (Date)
   - `category` (Relation: Posts belongs to one Category)

3. **Set Permissions** in Strapi Admin:
   - Go to Settings → Users & Permissions Plugin → Roles → Public
   - Enable `find` and `findOne` for both Categories and Posts
   - Save the settings

4. **Add Sample Content**:
   - Create a few categories (e.g., "Technology", "Tutorial")
   - Create some blog posts and assign them to categories
   - Make sure to publish the content

### Phoenix Application Setup

1. **Clone and navigate** to the example:
   ```bash
   cd examples/strapi_integration
   ```

2. **Install dependencies**:
   ```bash
   mix deps.get
   ```

3. **Configure Strapi URL and API Key**:
   ```bash
   export STRAPI_URL=http://localhost:1337
   export STRAPI_API_KEY=your_api_key_here  # Optional, for private APIs
   # Or set in config/dev.exs or config/runtime.exs
   ```

   **Note**: The API key is optional. If not provided, the integration will make public API calls. To generate an API key in Strapi, go to Settings > API Tokens in your Strapi admin panel.

## Running the Example

1. **Start your Strapi CMS**:
   ```bash
   # In your Strapi project directory
   npm run develop
   ```

2. **Start the Phoenix server**:
   ```bash
   # In the examples/strapi_integration directory
   mix phx.server
   ```

3. **Visit the application**:
   - Home page: http://localhost:4000
   - Blog index: http://localhost:4000/blog
   - Individual posts: http://localhost:4000/posts/{slug}
   - Category pages: http://localhost:4000/categories/{slug}

## Architecture Details

### Source Module (`StrapiSource`)

The `StrapiWeb.StrapiSource` module implements the `PhoenixStatic.Source` behavior:

```elixir
@behaviour PhoenixStatic.Source

@impl true
def list_pages() do
  # Fetches posts and categories from Strapi
  # Generates Page structs for all static pages
end

@impl true  
def last_modified() do
  # Returns timestamp of most recently updated content
  # Used for efficient recompilation
end
```

### API Integration

The module makes HTTP requests to Strapi's REST API:

- `GET /api/posts?populate=category` - Fetch posts with category data
- `GET /api/categories` - Fetch all categories
- `GET /api/posts?sort=updatedAt:desc&pagination[limit]=1` - Get last modified timestamp

### Page Generation

The source generates different types of pages:

1. **Post Pages**: Individual blog post pages with content and category info
2. **Category Pages**: Category overview with filtered posts
3. **Blog Index**: Main blog page with recent posts and category navigation

### Error Handling

The implementation includes comprehensive error handling:

- **API Failures**: Graceful fallback to minimal static pages
- **Network Issues**: Logging and fallback behavior  
- **Data Validation**: Safe handling of missing or malformed data
- **Timestamp Handling**: Fallback to current time if unable to determine last modified

### Configuration

Environment-based configuration for flexibility:

```elixir
# config/config.exs
config :phoenix_static_strapi_example,
  strapi_url: System.get_env("STRAPI_URL", "http://localhost:1337")

# config/runtime.exs
config :phoenix_static_strapi_example,
  strapi_url: System.get_env("STRAPI_URL") || "http://localhost:1337"
```

## Strapi API Structure

### Expected Strapi Response Format

**Posts API Response** (`/api/posts?populate=category`):
```json
{
  "data": [
    {
      "id": 1,
      "attributes": {
        "title": "My First Post",
        "slug": "my-first-post", 
        "content": "<p>Post content here...</p>",
        "publishedAt": "2024-01-15T10:00:00.000Z",
        "updatedAt": "2024-01-15T10:00:00.000Z",
        "category": {
          "data": {
            "id": 1,
            "attributes": {
              "name": "Technology",
              "slug": "technology"
            }
          }
        }
      }
    }
  ]
}
```

**Categories API Response** (`/api/categories`):
```json
{
  "data": [
    {
      "id": 1,
      "attributes": {
        "name": "Technology",
        "slug": "technology",
        "description": "Tech-related posts"
      }
    }
  ]
}
```

## Customization

### Adding New Content Types

1. **Create the content type** in Strapi
2. **Add API calls** in `StrapiSource.fetch_*` functions
3. **Generate pages** in `StrapiSource.generate_*_pages` functions
4. **Update last_modified** logic if needed

### Styling and Layout

- **CSS**: Add styles to `home.html.heex` or create separate CSS files
- **Templates**: Modify page generation in `StrapiSource` for custom HTML
- **Layout**: Update Phoenix layout files for different page structures

### API Authentication

For production deployments with authentication:

```elixir
defp headers() do
  [
    {"Content-Type", "application/json"},
    {"Accept", "application/json"},
    {"Authorization", "Bearer #{api_token()}"}
  ]
end

defp api_token() do
  Application.get_env(:phoenix_static_strapi_example, :strapi_api_token)
end
```

## Production Deployment

### Environment Variables

Set these environment variables in production:

```bash
STRAPI_URL=https://your-strapi-instance.com
SECRET_KEY_BASE=your_secret_key_base
PHX_HOST=your-domain.com
```

### Build Process

The static pages are generated at compile time:

1. **During compilation**, `StrapiSource.list_pages/0` is called
2. **Page content is fetched** from Strapi and embedded in the view module
3. **Routes are automatically generated** for all pages
4. **Recompilation** happens when source data changes (via `last_modified/0`)

### Performance Considerations

- **All content is held in memory** during compilation
- **Suitable for moderate amounts of content** (hundreds of pages)
- **Fast serving** since pages are pre-generated
- **Efficient recompilation** using last modified timestamps

## Troubleshooting

### Common Issues

1. **Connection refused**: Ensure Strapi is running on the configured URL
2. **Empty pages**: Check Strapi permissions for public access
3. **Content not updating**: Verify `last_modified/0` returns correct timestamp
4. **Build failures**: Check Strapi API response format matches expected structure

### Debug Mode

Enable detailed logging:

```elixir
# config/dev.exs
config :logger, level: :debug
```

View compilation details:
```bash
mix compile --verbose
```

## Related Documentation

- [Phoenix Static Library](../../README.md)
- [Strapi Documentation](https://docs.strapi.io/)
- [HTTPoison Documentation](https://hexdocs.pm/httpoison/)
- [Phoenix Framework](https://phoenixframework.org/)

## License

This example is provided under the same license as the phoenix_static library.