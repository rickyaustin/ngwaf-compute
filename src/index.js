/// <reference types="@fastly/js-compute" />
import { env } from "fastly:env";
import { includeBytes } from "fastly:experimental";


const welcomePage = includeBytes("./src/welcome-to-compute.html");

addEventListener("fetch", (event) => event.respondWith(handleRequest(event.request)));

async function handleRequest(request) {
    try {
        if (request.url.includes("/api")) {
            return await fetch(request, { backend: "origin_1" }); 
        } else {
            return await fetch(request, { backend: "origin_0" }); 
        }
    } catch (error) {
        console.error("Fetch error:", error);
        return new Response("The page you requested could not be found", {
            status: 404,
        });
    }
}
