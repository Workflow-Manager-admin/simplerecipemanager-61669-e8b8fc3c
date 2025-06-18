<script>
	// Color scheme constants
	const COLORS = {
		primary: "#4CAF50",
		secondary: "#FFC107",
		accent: "#FF5722",
		lightBackground: "#fafbfc",
		sidebarBackground: "#f5f6fa",
		text: "#222",
		border: "#e4e4e4"
	};

	// Application State
	let view = "list"; // "list" | "details" | "add"
	let recipes = [];
	let loading = false;
	let error = "";
	let selectedRecipe = null;

	// Form state for adding a new recipe
	let newRecipe = {
		title: "",
		description: "",
		ingredients: "",
		instructions: ""
	};
	let addError = "";

	// Fetch recipes from (mock or actual) API
	async function getRecipes() {
		loading = true;
		error = "";
		try {
			const res = await fetch("/api/recipes");
			if (!res.ok) throw new Error("Failed to fetch recipes");
			recipes = await res.json();
		} catch (e) {
			error = e.message;
		}
		loading = false;
	}

	// Fetch details of a single recipe
	async function getRecipeDetail(id) {
		loading = true;
		error = "";
		try {
			const res = await fetch(`/api/recipes/${id}`);
			if (!res.ok) throw new Error("Failed to fetch recipe");
			selectedRecipe = await res.json();
		} catch (e) {
			error = e.message;
		}
		loading = false;
	}

	// Add a new recipe via API
	async function addRecipe() {
		addError = "";
		if (!newRecipe.title.trim()) {
			addError = "Title is required.";
			return;
		}
		loading = true;
		try {
			const res = await fetch("/api/recipes", {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({
					...newRecipe,
					ingredients: (newRecipe.ingredients || "").split("\n").map(x => x.trim()).filter(Boolean),
					instructions: (newRecipe.instructions || "").split("\n").map(x => x.trim()).filter(Boolean)
				})
			});
			if (!res.ok) throw new Error("Could not add recipe");
			// Reset form, reload recipes and return to list view
			newRecipe = { title: "", description: "", ingredients: "", instructions: "" };
			view = "list";
			await getRecipes();
		} catch (e) {
			addError = e.message;
		}
		loading = false;
	}

	// Navigation actions
	function navigateToList() {
		view = "list";
		selectedRecipe = null;
		getRecipes();
	}
	function navigateToAddRecipe() {
		view = "add";
		selectedRecipe = null;
		addError = "";
	}

	function navigateToDetail(recipe) {
		selectedRecipe = null;
		view = "details";
		getRecipeDetail(recipe.id);
	}

	// On mount, load recipes
	import { onMount } from "svelte";
	onMount(() => {
		getRecipes();
	});
</script>

<style>
	:global(body) {
		background: #fafbfc;
		color: #222;
		font-family: 'Segoe UI', 'Roboto', sans-serif;
		margin: 0;
	}
	.container-main {
		display: flex;
		height: 100vh;
	}
	.sidebar {
		background: #f5f6fa;
		color: #4CAF50;
		width: 250px;
		padding: 2rem 1.5rem 1.5rem 1.5rem;
		box-shadow: 1px 0 8px 0 rgba(0,0,0,0.04);
		border-right: 1px solid #e4e4e4;
		display: flex;
		flex-direction: column;
		justify-content: space-between;
	}
	.sidebar h1 {
		font-size: 1.6rem;
		font-weight: bold;
		margin: 0 0 1rem 0;
		color: #4CAF50;
	}
	.nav-btn {
		background: none;
		border: none;
		color: #222;
		margin: 0.5rem 0;
		font-size: 1rem;
		padding: 0.7rem 0.6rem;
		text-align: left;
		cursor: pointer;
		border-radius: 6px;
		transition: background 0.19s;
	}
	.nav-btn.active, .nav-btn:hover {
		background: #4CAF50;
		color: white;
	}
	.content-area {
		flex: 1;
		background: #fafbfc;
		padding: 2rem 2rem 2rem 2rem;
		overflow-y: auto;
	}
	.recipe-list, .recipe-detail, .add-recipe-form {
		max-width: 700px;
		margin: 0 auto;
	}
	.recipe-card {
		background: white;
		border-radius: 8px;
		box-shadow: 0 2px 10px 0 rgba(44, 62, 80, 0.06);
		margin-bottom: 1.2rem;
		padding: 1.2rem 1.5rem;
		border: 1px solid #e4e4e4;
		cursor: pointer;
		transition: box-shadow 0.19s, border 0.14s;
	}
	.recipe-card:hover {
		box-shadow: 0 5px 22px 0 rgba(44, 62, 80, 0.11);
		border-color: #4CAF50;
	}
	.recipe-title {
		font-weight: 500;
		color: #4CAF50;
		margin: 0;
		font-size: 1.2rem;
		word-break: break-all;
	}
	.error-msg {
		color: #FF5722;
		padding: 0.7rem 1.2rem;
		background: #fff3e0;
		margin: 1.2rem 0;
		border-radius: 6px;
	}
	.btn-accent {
		color: white;
		background: #FF5722;
		border: none;
		border-radius: 6px;
		padding: 0.7rem 1.4rem;
		font-size: 1rem;
		cursor: pointer;
		font-weight: bold;
		margin-top: 1rem;
		transition: background 0.2s;
	}
	.btn-accent:hover {
		background: #e64a19;
	}
	label {
		color: #4CAF50;
		font-weight: 500;
		margin-top: 1rem;
		margin-bottom: 0.3rem;
		display: block;
	}
	input, textarea {
		width: 100%;
		margin-bottom: 1.1rem;
		border: 1.5px solid #e4e4e4;
		font-size: 1rem;
		padding: 0.7rem;
		border-radius: 5px;
		background: #fff;
		transition: border-color 0.17s;
	}
	input:focus, textarea:focus {
		outline: none;
		border-color: #4CAF50;
	}
	@media (max-width: 800px) {
		.container-main {
			flex-direction: column;
		}
		.sidebar {
			width: 100%;
			flex-direction: row;
			align-items: center;
			justify-content: space-between;
			padding: 1rem 1rem;
			border-right: none;
			border-bottom: 1px solid #e4e4e4;
		}
		.content-area {
			padding: 1rem 0.5rem;
		}
	}
</style>

<div class="container-main">
	<!-- Sidebar navigation -->
	<aside class="sidebar">
		<div>
			<h1>Simple Recipe<br>Manager</h1>
			<button class="nav-btn {view === 'list' ? 'active' : ''}" on:click={navigateToList}>Recipe List</button>
			<button class="nav-btn {view === 'add' ? 'active' : ''}" on:click={navigateToAddRecipe}>Add Recipe</button>
		</div>
		<footer style="font-size:0.99rem; color:#888">© {new Date().getFullYear()} SimpleRecipeManager</footer>
	</aside>

	<!-- Main Content -->
	<main class="content-area">
		{#if loading}
			<p>Loading...</p>
		{:else}
			{#if view === "list"}
				<section class="recipe-list">
					<h2 style="color: {COLORS.primary}; margin-bottom: 1.2rem;">Recipes</h2>
					{#if error}
						<div class="error-msg">{error}</div>
					{:else if recipes.length === 0}
						<p>No recipes found. Click 'Add Recipe' to get started!</p>
					{:else}
						{#each recipes as recipe (recipe.id)}
							<div class="recipe-card" on:click={() => navigateToDetail(recipe)}>
								<h3 class="recipe-title">{recipe.title}</h3>
								<div style="color:#888; font-size:0.97rem; margin-top:0.4rem;">
									{recipe.description}
								</div>
							</div>
						{/each}
					{/if}
				</section>
			{:else if view === "details" && selectedRecipe}
				<section class="recipe-detail">
					<h2 style="color: {COLORS.primary};">{selectedRecipe.title}</h2>
					{#if selectedRecipe.description}
						<p style="font-size: 1.09rem; color:#4d4d4d">{selectedRecipe.description}</p>
					{/if}
					{#if selectedRecipe.ingredients && selectedRecipe.ingredients.length > 0}
						<h4 style="margin-top:1.7rem; color:{COLORS.secondary}">Ingredients</h4>
						<ul>
							{#each selectedRecipe.ingredients as ing, i (i)}
								<li>{ing}</li>
							{/each}
						</ul>
					{/if}
					{#if selectedRecipe.instructions && selectedRecipe.instructions.length > 0}
						<h4 style="margin-top:1.1rem; color:{COLORS.secondary}">Instructions</h4>
						<ol>
							{#each selectedRecipe.instructions as step, i (i)}
								<li style="margin-bottom:0.7rem">{step}</li>
							{/each}
						</ol>
					{/if}
					<button class="btn-accent" style="margin-right:0.8rem;" on:click={navigateToList}>Back to List</button>
				</section>
			{:else if view === "add"}
				<section class="add-recipe-form">
					<h2 style="color: {COLORS.primary};">Add New Recipe</h2>
					{#if addError}
						<div class="error-msg">{addError}</div>
					{/if}
					<form on:submit|preventDefault={addRecipe}>
						<label for="title">Title</label>
						<input id="title" type="text" bind:value={newRecipe.title} required />

						<label for="description">Description</label>
						<input id="description" type="text" bind:value={newRecipe.description} />

						<label for="ingredients">Ingredients (one per line)</label>
						<textarea id="ingredients" rows="3" bind:value={newRecipe.ingredients}></textarea>

						<label for="instructions">Instructions (one step per line)</label>
						<textarea id="instructions" rows="5" bind:value={newRecipe.instructions}></textarea>

						<button class="btn-accent" type="submit">Add Recipe</button>
						<button type="button" class="nav-btn" style="margin-left:1.5rem;font-weight:600;" on:click={navigateToList}>Cancel</button>
					</form>
				</section>
			{:else if view === "details" && error}
				<div class="error-msg">{error}</div>
				<button class="btn-accent" type="button" on:click={navigateToList}>Back to List</button>
			{/if}
		{/if}
	</main>
</div>
