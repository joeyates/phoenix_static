# Phoenix Static + Strapi CMS Integration Example

This example demonstrates how to use `phoenix_static` with Strapi CMS as a content source to generate static pages at compile time.

## Overview

This example shows how to:

- **Fetch content from Strapi REST API** using Req HTTP client
- **Generate static pages** for blog posts, categories, and blog index
- **Handle relationships** between content types (Posts have many Categories)
- **Implement proper error handling** and fallbacks for API failures
- **Configure environment-based** Strapi API URLs and API keys
- **Track last modification times** for efficient recompilation (UNIX timestamps)

## Features Demonstrated

### Content Types
- **Posts**: Blog posts with title, content, slug, publication date, and category relationships
- **Categories**: Blog categories with name, slug, and description

### Generated Pages
- **Individual blog posts** at `/posts/{slug}`
- **Category pages** at `/categories/{slug}` with filtered posts
- **Blog index page** at `/blog` with recent posts and category list
- **Home page** at `/` with example documentation

### Phoenix Static Integration
- **Source Module**: `StrapiExample.Strapi.PostsSource` implements `PhoenixStatic.Source` behavior
- **Controller**: `StrapiExampleWeb.BlogController` uses `PhoenixStatic.Controller`
- **View**: `StrapiExampleWeb.BlogHTML` uses `PhoenixStatic.View`
- **Routes**: Automatically generated using `PhoenixStatic.Routes`

## Prerequisites

### Strapi CMS Setup

1. **Set up an online Strapi instance** (e.g., using Strapi Cloud, Railway, Heroku, or your own VPS):

2. **Create Content Types** in Strapi Admin Panel:

   **Categories Collection:**
   - `name` (Text, required)
   - `slug` (UID, required, target field: name)
   - `description` (Text, long text)

   **Posts Collection:**
   - `title` (Text, required)
   - `slug` (UID, required, target field: title)
   - `content` (Rich text, required)
   - `publishedAt` (Date)
   - `categories` (Relation: Posts has many Categories)

3. **Set API Permissions** in Strapi Admin:
   - Go to Settings → Users & Permissions Plugin → Roles → Public
   - **Disable** all public permissions (the API should not be public)
   - Create an API token for private access: Settings → API Tokens → Create new API Token
   - Set token type to "Read-only" and save the token value

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

3. **Configure Environment Variables**:
   ```bash
   export STRAPI_URL=https://your-strapi-instance.com
   export STRAPI_API_KEY=your_api_key_here
   ```

## Running the Example

1. **Ensure your online Strapi CMS is running** with the configured content types and API token.

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

### Source Module (`PostsSource`)

The `StrapiExample.Strapi.PostsSource` module (located in `lib/strapi_example/strapi/posts_source.ex`) implements the `PhoenixStatic.Source` behavior:

```elixir
@behaviour PhoenixStatic.Source

@impl true
def list_pages() do
  # Fetches posts and categories from Strapi
  # Generates Page structs for all static pages
end

@impl true  
def last_modified() do
  # Returns UNIX timestamp of most recently updated content
  # Used for efficient recompilation
end
```

### API Integration

The module makes HTTP requests to Strapi's REST API using required authentication:

- `GET /api/posts?populate=categories` - Fetch posts with category data
- `GET /api/categories` - Fetch all categories
- `GET /api/posts?sort=updatedAt:desc&pagination[limit]=1` - Get last modified UNIX timestamp

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

### Environment Configuration

Environment variables are read in `config/runtime.exs`:

```elixir
# config/runtime.exs
strapi_url = case System.get_env("STRAPI_URL") do
  nil -> raise "environment variable STRAPI_URL is missing"
  url -> url
end

strapi_api_key = System.get_env("STRAPI_API_KEY")

config :strapi_example,
  strapi_url: strapi_url,
  strapi_api_key: strapi_api_key
```

## Strapi API Structure

### Expected Strapi Response Format

**Posts API Response** (`/api/posts?populate=categories`):
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
        "categories": {
          "data": [
            {
              "id": 1,
              "attributes": {
                "name": "Technology",
                "slug": "technology"
              }
            },
            {
              "id": 2,
              "attributes": {
                "name": "Tutorial",
                "slug": "tutorial"
              }
            }
          ]
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

For each new content type, you must create:

1. **New source module** in `lib/strapi_example/strapi/` (e.g., `EventsSource` for events)
2. **New controller** using `PhoenixStatic.Controller`
3. **New view** using `PhoenixStatic.View` pointing to the new source module
4. **Update routes** to include the new controller

### Styling and Layout

- **Templates**: Modify page generation in source modules for custom HTML
- **Layout**: Update Phoenix layout files for different page structures
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

1. **Connection refused**: Ensure your online Strapi instance is accessible and running
2. **Authentication errors**: Verify the `STRAPI_API_KEY` environment variable is set correctly
3. **Content not updating**: Verify `last_modified/0` returns correct UNIX timestamp
4. **Build failures**: Check Strapi API response format matches expected structure

### Debug Mode

Enable detailed logging in `config/dev.exs`:

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
- [Req HTTP Client](https://hexdocs.pm/req/)
- [Phoenix Framework](https://phoenixframework.org/)

## License

This example is provided under the same license as the phoenix_static library.