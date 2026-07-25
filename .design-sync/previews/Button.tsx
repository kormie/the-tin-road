import React from "react";
import { Button, Stack } from "@tin-road/design-system";

export const Tones = () => (
	<Stack>
		<Button tone="primary">Travel to the next node</Button>
		<Button>Write a record</Button>
		<Button tone="danger">Send the ledger home by courier</Button>
	</Stack>
);

export const Inline = () => (
	<Button inline tone="primary">Post the standing order</Button>
);

export const Pressed = () => (
	<Stack>
		<Button tone="primary" autoFocus>Buy the pack and take the road</Button>
		<Button>Begin the next season</Button>
	</Stack>
);
