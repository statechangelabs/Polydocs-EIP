import { eth_requestAccounts } from "@raydeck/metamask-ts";
import { FC, useEffect } from "react";
import { FaGithub } from "react-icons/fa";
import { Link, Route, Routes } from "react-router-dom";
import { useAuthenticator } from "./Authenticator";
import { useMain } from "./DisconnectedMain";
import Editor from "./Editor";
import KnownTemplates from "./KnownTemplates";
import Title from "./Title";
import Topography from "./topography.svg";

const Disconnected: FC = () => {
  const { setHeaderVisible } = useMain();
  useEffect(() => {
    setHeaderVisible(false);
    return () => {
      setHeaderVisible(true);
    };
  }, []);
  const { authenticate } = useAuthenticator();
  return (
    <div
      className="h-screen w-full flex flex-col justify-center items-center"
      style={{ background: `url(${Topography})` }}
    >
      <div className="flex flex-col space-y-8">
        <Title />
        <div className="flex flex-row justify-center">
          <button
            className="btn btn-primary"
            onClick={async () => {
              const accounts = await eth_requestAccounts();
              console.log("I haz accounts", accounts);
              await authenticate();
              console.log("I am authenticated");
            }}
          >
            Connect to Metamask
          </button>
        </div>

        <div className="flex flex-row justify-center">
          <Link className="btn btn-gradient" to="/templates">
            View Document Templates
          </Link>
        </div>
      </div>
      <div className="fixed bottom-0 w-screen h-10 p-2 bg-black text-white flex flex-row space-between">
        <div className="text-xs hover:text-purple-400 transition">
          <a href="https://github.com/statechangelabs/polyDocs">
            <FaGithub className="h-6 w-6 mr-2 inline " />
            Source on GitHub
          </a>
        </div>
      </div>
    </div>
  );
};
export default Disconnected;
