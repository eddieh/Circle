/**
 * So actuallyEncodeURIComponent() is nice, but it doesn't encode quotes.
 * Here's a replacement that does.
 */

function actuallyEncodeURIComponent(component) {
	return encodeURIComponent(component).split("'").join("%27");
}